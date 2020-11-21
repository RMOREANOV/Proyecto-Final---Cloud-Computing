import 'package:flutter/cupertino.dart';

navigatorPushReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation =
              CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
          return ScaleTransition(
            alignment: Alignment.center,
            scale: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return widget;
        },
      ));
}

navigatorPush(BuildContext context, Widget widget) {
  Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation =
              CurvedAnimation(parent: animation, curve: Curves.elasticInOut);
          return ScaleTransition(
            alignment: Alignment.center,
            scale: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return widget;
        },
      ));
}
