import 'package:dgg/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';

enum BottomSheetType {
  messageAction,
}

enum MessageActionSheetResponse {
  copy,
  reply,
}

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.messageAction: (context, sheetRequest, completer) =>
        _MessageActionBottomSheet(request: sheetRequest, completer: completer)
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}

class _MessageActionBottomSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const _MessageActionBottomSheet({
    Key key,
    this.request,
    this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            Icons.copy,
            "Copy message",
            MessageActionSheetResponse.copy,
          ),
          _buildItem(
            Icons.reply,
            "Reply to ${request.customData.user.nick}",
            MessageActionSheetResponse.reply,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      IconData icon, String text, MessageActionSheetResponse data) {
    return GestureDetector(
      onTap: () => completer(SheetResponse(responseData: data)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 16, bottom: 16),
            child: Icon(
              icon,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
