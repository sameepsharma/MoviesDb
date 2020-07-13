import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'APIs.dart';
import 'model/Results.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
        title: 'The Movie DB',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage()
    );
  }

}


class HomePage extends StatefulWidget {

  HomePage({Key key}) :super(key: key);

  @override
  HomeState createState() {
    // TODO: implement createState
    return HomeState();
  }

}

class HomeState extends State {
  List<Results> mainList=new List();
  int currPage=1;
  bool isSearch=false;

  void callSearchApi(String text) {

  }

  List<Results> createMDBList(var data) {
    List<Results> list = new List();
    for (int i = 0; i < data.length; i++) {
      String poster_path = data[i]["poster_path"];
      String original_title = data[i]["original_title"];
      String title = data[i]["title"];
      String overview = data[i]["overview"];
      dynamic vote_average = data[i]["vote_average"];
      Results result = new Results(
          poster_path: poster_path,
          original_title: original_title,
          title: title,
          overview: overview,
          vote_average: vote_average);
      list.add(result);
    }
    return list;
  }

  getMoreData(){
    setState(() {
      currPage++;
      print("PAge>> " + currPage.toString());
      fetchMDB(now_playing+currPage.toString());
    });
  }

  Future<List<Results>> fetchMDB(String url) async {
    final response = await http.get(url);
    var responseJson = json.decode(response.body.toString());
    List<Results> userList = createMDBList(responseJson['results'] as List);
    /*if(isSearch){
      setState(() {
        mainList.clear();
        mainList.addAll(createMDBList(responseJson['results'] as List));
        isSearch=true;
      });
      }else*/
    //{
      setState(() {
        mainList.addAll(userList);
      });

    //}

    return userList;
  }


  @override
  Widget build(BuildContext context) {
ScrollController _controller = new ScrollController();
_controller.addListener(() {
  if(_controller.position.pixels==_controller.position.maxScrollExtent){
      getMoreData();
  }

});

    return new Scaffold(
        appBar: new AppBar(
          title: new Text('The Movie DB'),
        ),
        body: new Padding(
            padding: EdgeInsets.all(15),
            child: new Column(
              children: <Widget>[
                new TextField(
                  onChanged: (text) {
                    if(text.length>3)
                    callSearchApi(text);
                    else
                      callSearchApi(now_playing+currPage.toString());
                  },
                  autofocus: false,
                  decoration: InputDecoration(hintText: 'Search Movie')
                ),
                SizedBox(height: 10),
                new Container(
                  child: new FutureBuilder<List<Results>>(
                    future: fetchMDB(now_playing+currPage.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return new Expanded(
                            child: new ListView.builder(
                              controller: _controller,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      startAddNewTransaction(
                                          context, snapshot.data[index]);
                                    },
                                    child: new Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 80,
                                            child: new Card(
                                              child: Row(
                                                children: [
                                                  Image.network(imagePath +
                                                      snapshot.data[index]
                                                          .poster_path),
                                                  SizedBox(width: 10),
                                                  Container(
                                                    width: 300,
                                                    child: Text(
                                                      snapshot
                                                          .data[index].title,
                                                      style: new TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 20),
                                                      textAlign:
                                                      TextAlign.left,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                  );
                                }));
                      } else if (snapshot.hasError) {
                        return new Text("${snapshot.error}");
                      }
                      // show a loading spinner
                      return new Center(
                          child: new CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            )
        )
    );
  }

  void startAddNewTransaction(BuildContext ctx, Results result) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return Container(
            width: double.infinity,
            child: Card(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    imagePath + result.poster_path,
                    fit: BoxFit.fitWidth,
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.black45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          result.title,
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Avg Rating : " + result.vote_average.toString(),
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          result.overview,
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
