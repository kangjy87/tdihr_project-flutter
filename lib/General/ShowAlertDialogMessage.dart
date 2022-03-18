import 'package:flutter/material.dart';

showAlertDialogMessage(BuildContext context, String strTitle, String strMsg1,String? strMsg2,
    String strBtn1, String? strBtn2, Function onclickEvent1, Function? onclickEvent2) {
  List<Widget> btns(){
    if(strBtn2 != null){
      return [
        FlatButton(
          child: Text(strBtn1),
          onPressed: (){
            onclickEvent1();
          },
        ),
        FlatButton(
          child: Text(strBtn2),
          onPressed: (){
            onclickEvent2!();
          },
        )
      ];
    }else{
      return [
        FlatButton(
          child: Text(strBtn1),
          onPressed: (){
            onclickEvent1();
          },
        ),
      ];
    }
  }
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(strTitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(strMsg1),
                Text(strMsg2 != null ? strMsg2 : ""),
              ],
            ),
          ),
          actions: btns(),
        );
      });
}
