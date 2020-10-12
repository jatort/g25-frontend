import 'dart:convert';

import 'package:http/http.dart' as http;

class GenerateImageUrl {
  bool success;
  String message;

  bool isGenerated;

  String uploadUrl;
  String downloadUrl;

  Future<void> call(String fileType) async {
    try {
      Map body = {"fileType": fileType};

      var response = await http.post(
<<<<<<< HEAD
        //For IOS
//        'http://localhost:5000/generatePresignedUrl',
        //For Android
        'https://serverimagee1.herokuapp.com/',
=======
        'https://serverimagee1.herokuapp.com/generatePresignedUrl',
>>>>>>> 92e8fb936b8ecf02acf0714b33258283dd342d8f
        body: body,
      );

      var result = jsonDecode(response.body);

      if (result['success'] != null) {
        success = result['success'];
        message = result['message'];

        if (response.statusCode == 201) {
          isGenerated = true;
          uploadUrl = result["uploadUrl"];
          downloadUrl = result["downloadUrl"];
        }
      }
    } catch (e) {
      throw ('Error getting url');
    }
  }
}
