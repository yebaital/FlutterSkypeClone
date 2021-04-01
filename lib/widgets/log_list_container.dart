import 'package:flutter/material.dart';
import 'package:skype_clone/constants/strings.dart';
import 'package:skype_clone/models/log.dart';
import 'package:skype_clone/resources/local_db/repository/log_repository.dart';
import 'package:skype_clone/utils/utilities.dart';
import 'package:skype_clone/widgets/cached_image.dart';
import 'package:skype_clone/widgets/custom_tile.dart';
import 'package:skype_clone/widgets/quiet_box.dart';

class LogListContainer extends StatefulWidget {
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;
      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          size: _iconSize,
          color: Colors.red,
        );
        break;
      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: LogRepository.getLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;
          if (logList.isNotEmpty) {
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, index) {
                Log _log = logList[index];
                bool hasDialled = _log.callStatus == CALL_STATUS_DIALLED;
                return CustomTile(
                  leading: CachedImage(
                    hasDialled ? _log.receiverPic : _log.callerPic,
                    isRound: true,
                    radius: 45,
                  ),
                  mini: false,
                  title: Text(
                    hasDialled ? _log.receiverName : _log.callerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  subtitle: Text(
                    Utils.formatDateString(_log.timestamp),
                    style: TextStyle(fontSize: 13),
                  ),
                  icon: getIcon(_log.callStatus),
                  onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Delete this log?"),
                            content: Text(
                                "Are you sure you want to delete this log?"),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.maybePop(context);
                                  await LogRepository.deleteLogs(index);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Text("Yes"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.maybePop(context),
                                child: Text("No"),
                              ),
                            ],
                          )),
                );
              },
            );
          }
          return QuietBox();
        }
        return Text("No call logs");
      },
    );
  }
}
