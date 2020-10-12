import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chat_e1/custom_dialog.dart';
import 'package:chat_e1/upload_file.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'gallery_item.dart';
import 'generate_image_url.dart';
import 'gallery_photo_wrapper.dart';
import 'delete_widget.dart';

const Color kErrorRed = Colors.redAccent;
const Color kDarkGray = Color(0xFFA3A3A3);
const Color kLightGray = Color(0xFFF1F0F5);

class Images extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

enum PhotoStatus { LOADING, ERROR, LOADED }
enum PhotoSource { FILE, NETWORK }

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImagePickerWidget();
  }
}

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> _photos = List<File>();
  List<String> _photosUrls = List<String>();

  List<PhotoStatus> _photosStatus = List<PhotoStatus>();
  List<PhotoSource> _photosSources = List<PhotoSource>();
  List<GalleryItem> _galleryItems = List<GalleryItem>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhoto();
                }
                File image = _photos[index - 1];
                PhotoSource source = _photosSources[index - 1];
                return Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () => _onPhotoClicked(index - 1),
                      child: Container(
                        margin: EdgeInsets.all(5),
                        height: 100,
                        width: 100,
                        color: kLightGray,
                        child: source == PhotoSource.FILE
                            ? Image.file(image)
                            : Image.network(_photosUrls[index - 1]),
                      ),
                    ),
                    Visibility(
                      visible: _photosStatus[index - 1] == PhotoStatus.LOADING,
                      child: Positioned.fill(
                        child: SpinKitWave(
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _photosStatus[index - 1] == PhotoStatus.ERROR,
                      child: Positioned.fill(
                        child: Icon(
                          MaterialIcons.error,
                          color: kErrorRed,
                          size: 35,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        padding: EdgeInsets.all(6),
                        alignment: Alignment.topRight,
                        child: DeleteWidget(
                          () => _onDeleteReviewPhotoClicked(index - 1),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(16),
            child: RaisedButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.pop(context, _photosUrls);
              },
            ),
          )
        ],
      ),
    );
  }

  _buildAddPhoto() {
    return InkWell(
      onTap: () => _onAddPhotoClicked(context),
      child: Container(
        margin: EdgeInsets.all(5),
        height: 100,
        width: 100,
        color: kDarkGray,
        child: Center(
          child: Icon(
            MaterialIcons.add_to_photos,
            color: kLightGray,
          ),
        ),
      ),
    );
  }

  _onAddPhotoClicked(context) async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    PermissionStatus permissionStatus = await permission.status;

    if (permissionStatus == PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.undetermined) {
      permissionStatus = await permission.request();

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == PermissionStatus.granted) {
      File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        int length;
        length = _photos.length + 1;

        String fileExtension = path.extension(image.path);

        _galleryItems.add(
          GalleryItem(
            id: Uuid().v1(),
            resource: image.path,
            isSvg: fileExtension.toLowerCase() == ".svg",
          ),
        );

        setState(() {
          _photos.add(image);
          _photosStatus.add(PhotoStatus.LOADING);
          _photosSources.add(PhotoSource.FILE);
        });

        try {
          GenerateImageUrl generateImageUrl = GenerateImageUrl();
          await generateImageUrl.call(fileExtension);

          String uploadUrl;
          if (generateImageUrl.isGenerated != null &&
              generateImageUrl.isGenerated) {
            uploadUrl = generateImageUrl.uploadUrl;
          } else {
            throw generateImageUrl.message;
          }

          bool isUploaded = await uploadFile(context, uploadUrl, image);
          if (isUploaded) {
            setState(() {
              _photosUrls.add(generateImageUrl.downloadUrl);
              _photosStatus
                  .replaceRange(length - 1, length, [PhotoStatus.LOADED]);
              _galleryItems[length - 1].resource = generateImageUrl.downloadUrl;
            });
          }
        } catch (e) {
          setState(() {
            _photosStatus[length - 1] = PhotoStatus.ERROR;
          });
        }
      }
    }
  }

  Future<bool> uploadFile(context, String url, File image) async {
    try {
      UploadFile uploadFile = UploadFile();
      await uploadFile.call(url, image);

      if (uploadFile.isUploaded != null && uploadFile.isUploaded) {
        return true;
      } else {
        throw uploadFile.message;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> _onDeleteReviewPhotoClicked(int index) async {
    if (_photosStatus[index] == PhotoStatus.LOADED) {
      _photosUrls.removeAt(index);
    }
    _photos.removeAt(index);
    _photosStatus.removeAt(index);
    _photosSources.removeAt(index);
    _galleryItems.removeAt(index);
    setState(() {});
    return true;
  }

  _showOpenAppSettingsDialog(context) {
    return CustomDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }

  _onPhotoClicked(int index) {
    if (_photosStatus[index] == PhotoStatus.ERROR) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: _galleryItems,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
