
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trendyhashtags/screens/view_tags.dart';
import 'package:trendyhashtags/util.dart';

import 'appbar.dart';
import 'fab.dart';
import 'fab_bottom_app_bar.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:trendyhashtags/service/hashtag_serviceimpl.dart';
Future<void> main()  {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    hashtag_serviceimpl.loadHashTagData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }


}

final darkTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(),
  iconTheme: IconThemeData(color: Colors.white),
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key,  this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List <Widget> screens  = [];
  int _counter = 0;
  int _lastSelected = 0;
  int prevIndex =0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _editController = TextEditingController();
  TabController _tabController;
  view_tags modal = view_tags();

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Future<void> initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _editController.clear();

  }

  void _selectedTab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(screens.isEmpty){
      prepare_screens();
    }
    return Scaffold(
      appBar: emptyAppbar(),
      body: screens[_lastSelected],
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: 'Search',
        color: Colors.grey,
        selectedColor: Colors.blue,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: Icons.home, text: 'Home'),
          FABBottomAppBarItem(iconData: Icons.category, text: 'Categories'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: customFab(context, _tabController, _formKey, _editController),
     /* floatingActionButton: _buildFab(
          context), */// This trailing comma makes auto-formatting nicer for build methods.
    );
  }




  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  List <Widget> get_recent_list(){
    bool isEntered = false;
    List <Widget> listWidgets  = [];


    listWidgets.add(Container(
      height: 30.0,
      width: 42.0,
      margin: EdgeInsets.only(top: 15, left: 20, bottom: 08, right: 15),
      child: Text(
        'Recently Searched',
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            foreground: Paint()..shader = linearGradient),
      ),
    ));

    if(hashtag_serviceimpl.localStorage !=null){
      int index = 0;
      hashtag_serviceimpl.localStorage.getKeys().forEach((element) {
        if(element.endsWith('_recent')){
          isEntered = true;
          var trendingHashtags = jsonDecode(hashtag_serviceimpl.localStorage.get(element));
          listWidgets.add(get_container(trendingHashtags['hashtags'], index));
          index++;
        }
      });
    }
    listWidgets.add(const SizedBox(height: 15));
    if(!isEntered){
      listWidgets.clear();
    }
    return listWidgets;
  }

  Widget noContentScreen(){
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/noDataFound.png',
              // height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: const Text('Oops!', textAlign: TextAlign.center),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            child: const Text('No Recently Searched hashtags are found!',
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );

  }


  Container get_container(String text, int index){
    return  Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
      padding: EdgeInsets.fromLTRB(5, 13, 5, 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 260,
            child: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: CustomColors.BellGrey),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: text)).then((_) {
                this._editController.clear();
                hashtag_serviceimpl.showSnackbar(context,
                    'Hashtags are copied to clipboard', 3, Colors.lightGreen);
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.white70,
              child:Icon(
                  Icons.copy_rounded
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          //  stops: [0.015, 0.015],
          colors: [cardcolor(index),cardcolor(index)],
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.GreyBorder,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
    );
  }
  Color cardcolor(int index){
    int indx = prevIndex;
    if(prevIndex>=3){
      prevIndex = 0;
      indx = prevIndex;
    }
    prevIndex++;
    return CustomColors.cardcolors.elementAt(indx);
  }

  List <Widget> prepare_screens(){
    //home screen
    screens.add(categoryWidegt(context, 'HOME'));
    // categories
    screens.add(categoryWidegt(context, 'CAT'));

  }
  Widget homeScreen(context){
    List <Widget> listWidgets = get_recent_list();
    if(listWidgets.isNotEmpty){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: listWidgets,
        ),
      );
    }else {
      return noContentScreen();
    }
  }

  Widget categoriesScreen(context){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) => Container(
                  margin: EdgeInsets.only(left: 10, top: 15, bottom: 0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()..shader = linearGradient),
                  ),
                ),
                childCount: 1),
          ),
          SliverGrid.count(
            crossAxisCount: 3,
            children: get_categories(context),
          ),
        ],
      ),
    );
  }


  Widget categoryWidegt(context, screen) {
    return FutureBuilder(
      builder: (context, projectSnap) {
        if(screen == 'CAT'){
          if (projectSnap.connectionState == ConnectionState.none &&
              projectSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
          }
          return categoriesScreen(context);
        }else {
          return homeScreen(context);
        }
      },
      future: get_categories_boxes(context),
    );
  }

  Future get_categories_boxes(BuildContext context) async {

    if (hashtag_serviceimpl.localStorage == null) {
      SharedPreferences localStorage = await hashtag_serviceimpl.init();
      if (localStorage != null) {
        bool result = await hashtag_serviceimpl.loadHashTagData();
        if (result) {
          return localStorage;
        }
      }
    } else {
      return hashtag_serviceimpl.localStorage;
    }
  }

  List<Widget> get_categories(BuildContext context) {
    List<InkWell> containers = [];
    if(hashtag_serviceimpl.localStorage != null) {
      CustomColors.items.forEach((element) {
        String imagePath = element.icon;
        var trendingHashtag = jsonDecode(hashtag_serviceimpl.localStorage
            .getString(element.title.toString() + '_top'));
        containers.add(InkWell(
            onTap: () {
              _tabController.index = 0;
              modal.mainBottomSheet(context, trendingHashtag, _tabController,
                  _editController, false, _formKey);
            },
            child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        child: Image.asset(imagePath),
                        decoration: new BoxDecoration(
                          color: CustomColors.BellGrey,
                          borderRadius: BorderRadius.all(
                            Radius.circular(70.0),
                          ),
                          /*image: new DecorationImage(
                          image: new AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),*/
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        element.title.toString(),
                        style: TextStyle(
                            fontSize: 14,
                            color: CustomColors.TextWhite,
                            fontWeight: FontWeight.w600),
                      ),

                    ],
                  ),
                ),
                /*decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(),
                  ],
              //    color: Colors.blueGrey
              ),*/
                margin: EdgeInsets.all(10),
                height: 150.0)));
      });
    }
    return containers;
  }
}
