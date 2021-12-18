import 'package:flutter/material.dart';
import 'package:trendyhashtags/screens/view_tags.dart';
import 'util.dart';


FloatingActionButton customFab(BuildContext context, TabController _tabController, GlobalKey _formKey, TextEditingController _editController) {
  view_tags modal = view_tags();
  return FloatingActionButton(
    onPressed: () {
      modal.mainBottomSheet(context, null, _tabController, _editController, true, _formKey);
    },
    elevation: 5,
    backgroundColor: Colors.transparent,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: CircleAvatar(
        child:Icon(
            Icons.search
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            CustomColors.PurpleLight,
            CustomColors.PurpleDark,
          ],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.BlueLight,
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
    ),
  );
}
