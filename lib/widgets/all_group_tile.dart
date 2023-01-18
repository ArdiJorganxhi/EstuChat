import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';
import '../pages/group_info.dart';
import '../service/database_service.dart';

class AllGroupTile extends StatefulWidget {
  final String groupName;
  final String groupId;
  final String userName;
  final String admin;

  const AllGroupTile(
      {Key? key,
      required this.userName,
      required this.groupId,
      required this.groupName,
      required this.admin})
      : super(key: key);

  @override
  State<AllGroupTile> createState() => _AllGroupTileState();
}

class _AllGroupTileState extends State<AllGroupTile> {
  String userName = "";
  bool isJoinedAllGroups = false;

  User? user;
  Stream<QuerySnapshot>? allGroups;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
    getAllGroups();
  }

  getAllGroups() async {
    DatabaseService().getAllGroups().then((val) {
      setState(() {
        allGroups = val;
      });
    });
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  String getAdmin(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  joinedOrNot(
      String userName, String groupId, String groupname, String admin) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupname, groupId, userName)
        .then((value) {
      setState(() {
        isJoinedAllGroups = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    joinedOrNot(userName, widget.groupId, widget.groupName, widget.admin);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          widget.groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(widget.groupName,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text("Yönetici: ${getAdmin(widget.admin)}"),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleGroupJoin(widget.groupId, userName, widget.groupName);
          if (isJoinedAllGroups) {
            setState(() {
              isJoinedAllGroups = !isJoinedAllGroups;
            });

          } else {
            setState(() {
              isJoinedAllGroups = !isJoinedAllGroups;

            });
          }
        },
        child: isJoinedAllGroups
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  "Katıldı",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text("Katıl",
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}
