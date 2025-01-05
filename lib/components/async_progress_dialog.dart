import 'package:flutter/material.dart';

/// This code is an extension to the package flutter_progress_dialog (https://pub.dev/packages/future_progress_dialog)

const _DefaultDecoration = BoxDecoration(
  color: Colors.white,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class AsyncProgressDialog extends StatefulWidget {
  /// Dialog will be closed when [future] task is finished.

  final Future future;

  /// [BoxDecoration] of [AsyncProgressDialog].
  final BoxDecoration? decoration;

  /// opacity of [AsyncProgressDialog]
  final double opacity;

  /// If you want to use custom progress widget set [progress].
  final Widget? progress;

  /// If you want to use message widget set [message].
  final Widget message;

  /// On error handler
  final Function? onError;

  AsyncProgressDialog(
    this.future, {
    this.decoration,
    this.opacity = 1.0,
    this.progress,
    required this.message,
    this.onError,
  });

  @override
  State<AsyncProgressDialog> createState() => _AsyncProgressDialogState();
}

class _AsyncProgressDialogState extends State<AsyncProgressDialog> {
  @override
  void initState() {
    widget.future.then((val) {
      Navigator.of(context).pop(val);
    }).catchError((e) {
      Navigator.of(context).pop();
      widget.onError?.call(e);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: _buildDialog(context),
      onWillPop: () {
        return Future(() {
          return false;
        });
      },
    );
  }

  Widget _buildDialog(BuildContext context) {
    var content;
    content = Container(
      height: 100,
      padding: const EdgeInsets.all(20),
      decoration: widget.decoration ?? _DefaultDecoration,
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        widget.progress ?? CircularProgressIndicator(),
        SizedBox(width: 20),
        _buildText(context)
      ]),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Opacity(
        opacity: widget.opacity,
        child: content,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Expanded(
      flex: 1,
      child: widget.message,
    );
  }
}
