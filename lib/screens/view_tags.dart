import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dialog_builder.dart';
import 'package:trendyhashtags/service/hashtag_serviceimpl.dart';
import 'package:trendyhashtags/util.dart';

class view_tags {
  TextEditingController _editController;

  static TextEditingController _textFieldController = TextEditingController();
  List<Widget> bodyElements = [];

  HashMap tempHashMap = null;

  void clearText() {
    _textFieldController.clear();
  }

  mainBottomSheet(
      BuildContext context,
      var trending_hashtag,
      TabController _tabController,
      TextEditingController _editController,
      bool isSearch,
      GlobalKey _formKey) {
    tempHashMap = new HashMap<String, String>();
    this._editController = _editController;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Container(
            height: MediaQuery.of(context).size.height - 80,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Positioned(
                  top: MediaQuery.of(context).size.height / 25,
                  left: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(175, 30),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  // top: MediaQuery.of(context).size.height / 2 - 360,
                  top: 15,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            clearText();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            child: Image.asset('assets/images/fab-delete.png'),
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
                                  color: CustomColors.PurpleShadow,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                  offset: Offset(0.0, 0.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        column_based_on_flag(context, trending_hashtag,
                            _tabController, isSearch, _formKey, setState),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  final List<Widget> myTabs = [
    Center(
      child: Container(
        child: Text('Trending', textAlign: TextAlign.center),
      ),
    ),
    Center(
      child: Container(
        child: Text('Popular', textAlign: TextAlign.center),
      ),
    ),
    Center(
      child: Container(
        child: Text('Random', textAlign: TextAlign.center),
      ),
    ),
  ];

  void changeTags(String text) {
    _editController.text = text;
  }

  Container container_form(String text) {
    changeTags(text);
    return Container(
      //margin: const EdgeInsets.only(bottom: 2.0),
      child: TextFormField(
        //initialValue: text,
        controller: _editController,
        maxLines: 4,
        readOnly: true,
        autofocus: false,
        style: TextStyle(
          fontSize: 15,
          fontStyle: FontStyle.normal,
          color: Colors.white70,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addDataToMap(context, keyword) async {
    DialogBuilder dialogBuilder = DialogBuilder(context, true);
    dialogBuilder.showLoadingIndicator('Searching ...', 'Loading...');
    String tags = await hashtag_serviceimpl.query(keyword, 'top', false);
    if (tags != null && tags.isNotEmpty) {
      tempHashMap.putIfAbsent(keyword + '_top', () => tags);
      tags = await hashtag_serviceimpl.query(keyword, 'live', false).whenComplete(() => tempHashMap.putIfAbsent(keyword + '_live', () => tags));
      tags = await hashtag_serviceimpl.query(keyword, 'random', false).whenComplete(() => tempHashMap.putIfAbsent(keyword + '_random', () => tags));
      dialogBuilder.hideOpenDialog();
    } else {
      dialogBuilder.hideOpenDialog();
      Navigator.of(context).pop();
      hashtag_serviceimpl.showSnackbar(
          context, 'No Hashtags are found for given word', 3, Colors.redAccent);
    }
  }

  column_based_on_flag(
      BuildContext context,
      var trending_hashtag,
      TabController _tabController,
      bool isSearch,
      GlobalKey _formKey,
      StateSetter setState) {
    String keyword;
    if (isSearch) {
     // clearText();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 30),
          Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 100,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green)),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _textFieldController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                    labelText: 'Enter keyword',
                    // labelStyle : TextStyle( color: Colors.red),
                    focusColor: Colors.red,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: clearText,
                    ),
                  ),
                  validator: (name) {
                    if (name.isEmpty) {
                      return 'Invalid keyword';
                    }
                  },
                  onSaved: (name) => keyword = name,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          RaisedButton(
            onPressed: () async {
              await addDataToMap(context, _textFieldController.text.toString()).whenComplete(() 
                async {
              //  if(_textFieldController.text.isNotEmpty){
                  _tabController.index = 0;
                  List widgets = await addBodyElement(context, _tabController, true,
                      trending_hashtag, _textFieldController.text.toString());
                  if(widgets.isNotEmpty){
                    setState(() {
                      bodyElements = widgets;
                    });
                  }
               // }
                });
            },
            textColor: Colors.white,
            padding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Container(
              width: 120,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    CustomColors.BlueLight,
                    CustomColors.BlueDark,
                  ],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.BlueShadow,
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.0, 0.0),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Center(
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: bodyElements,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children:
            addBodyElementNonAsync(context, _tabController, trending_hashtag),
      );
    }
  }

  List addBodyElementNonAsync(context, _tabController, trending_hashtag) {
    bodyElements = [];
    String tags = '';
    bool insideTabs = false;
    bodyElements.add(SizedBox(height: 30));
    bodyElements.add(Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: CustomColors.GreyBorder,
          ),
          bottom: BorderSide(
            width: 1.0,
            color: CustomColors.GreyBorder,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        tabs: myTabs,
        onTap: (value) async {
          insideTabs = true;
          var trending_hashtags;
          String tab = '';
          if (value == 0) {
            tab = 'top';
          } else if (value == 1) {
            tab = 'live';
          } else if (value == 2) {
            tab = 'random';
          }
          trending_hashtags = jsonDecode(hashtag_serviceimpl.localStorage
              .getString(trending_hashtag['category'] + '_' + tab));
          if (tab == 'random') {
            String tagss = trending_hashtags['hashtags'];
            List list = tagss.split(" ");
            tagss = '';
            for (var element in list.reversed) {
              tagss += element + ' ';
            }
            trending_hashtags['hashtags'] = tagss;
          }
          tags = trending_hashtags['hashtags'];
          changeTags(tags);
        },
      ),
    ));

    bodyElements.add(SizedBox(height: 30));
    if (_tabController.index == 0 && !insideTabs) {
      tags = trending_hashtag['hashtags'];
    }
    bodyElements.add(textFormField(context, tags));
    bodyElements.add(copyButton(context, tags));

    return bodyElements;
  }

  Container textFormField(context, tags) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 150,
      child: container_form(tags),
    );
  }

  Future<List> addBodyElement(context, _tabController, isSearchAction,
      trending_hashtag, keyword) async {
    bodyElements = [];
    String tags = '';
    bool insideTabs = false;
    bodyElements.add(SizedBox(height: 30));
    bodyElements.add(Container(
      width: MediaQuery.of(context).size.width / 1.2,
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1.0,
            color: CustomColors.GreyBorder,
          ),
          bottom: BorderSide(
            width: 1.0,
            color: CustomColors.GreyBorder,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        tabs: myTabs,
        onTap: (value) async {
          var trending_hashtags;
          String tab = '';
          if (value == 0) {
            tab = 'top';
          } else if (value == 1) {
            tab = 'live';
          } else if (value == 2) {
            tab = 'random';
          }
          if (!isSearchAction) {
            trending_hashtags = jsonDecode(hashtag_serviceimpl.localStorage
                .getString(trending_hashtag['category'] + '_' + tab));
            if (tab == 'random') {
              String tagss = trending_hashtags['hashtags'];
              List list = tagss.split(" ");
              tagss = '';
              for (var element in list.reversed) {
                tagss += element + ' ';
              }
              trending_hashtags['hashtags'] = tagss;
            }
            tags = trending_hashtags['hashtags'];
          } else {
            insideTabs = true;
            String key = keyword + '_' + tab;
            if (tempHashMap.containsKey(key)) {
              tags = tempHashMap[key];
            }
          }
          changeTags(tags);
        },
      ),
    ));

    bodyElements.add(SizedBox(height: 30));
    if (_tabController.index == 0 && !insideTabs) {
      String key = keyword + '_top';
      if (tempHashMap.containsKey(key)) {
        tags = tempHashMap[key];
      }
    }
    bodyElements.add(textFormField(context, tags));
    bodyElements.add(copyButton(context, tags));

    return bodyElements;
  }


  RaisedButton copyButton(context, tags) {
    return RaisedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: tags)).then((_) {
          clearText();
          Navigator.pop(context); // hiding bottom sheet
          hashtag_serviceimpl.showSnackbar(context,
              'Hashtags are copied to clipboard', 3, Colors.lightGreen);
        });
      },
      textColor: Colors.white,
      padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: 140,
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              CustomColors.BlueLight,
              CustomColors.BlueDark,
            ],
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          boxShadow: [
            BoxShadow(
              color: CustomColors.BlueShadow,
              blurRadius: 1.0,
              spreadRadius: 0.5,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Center(
          child: const Text(
            'Copy Hashtags',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
