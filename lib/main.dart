import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aqui',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WebPage(),
    );
  }
}

class WebPage extends StatefulWidget {
  @override
  _WebPageState createState() => _WebPageState();
}


class _WebPageState extends State<WebPage> with SingleTickerProviderStateMixin{
  InAppWebViewController webView;
  String indexUrl = 'https://aqui.e-node.net/';

  bool showErrorPage = false;
  bool loading = true;
  String url ="";

  LocalStorage storage = new LocalStorage('/uris');
  JsonCodec json = JsonCodec();
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

/*
  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: Container(
            child: Column(children: <Widget>[
              Expanded(

                child: Container(

                  child: InAppWebView(
                    //initialUrl: "https://aqui.e-node.net",
                    initialData: InAppWebViewInitialData(data : kNavigationExamplePage),
                    initialHeaders: {},
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;


                    },

                    onLoadStart: (InAppWebViewController controller, String url) async {

                      var connectivityResult = await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        await controller.loadData(data: json.decode(await getHTML(storage, url)));
                      }
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      var connectivityResult = await (Connectivity().checkConnectivity());
                      if (connectivityResult != ConnectivityResult.none) {
                        await controller.getHtml().then((value) => {
                          insertStorage(url, storage,value)
                        });
                      }

                    },
                    onLoadError: (InAppWebViewController controller, String url, int code, String message) async {
                      var tRexHtml = await controller.getTRexRunnerHtml();
                      var tRexCss = await controller.getTRexRunnerCss();
                      await getHTML(storage, url);





                    },
                    onLoadHttpError: (InAppWebViewController controller, String url, int statusCode, String description) async {
                      print("HTTP error $url: $statusCode, $description");
                    },
                    showErrorPage ? Center(
                      child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        height: double.infinity,
                        width: double.infinity,
                        child: Text('Page failed to open (WIDGET)'),
                      ),
                    ) : SizedBox(height: 0, width: 0),
                  ),
                ),
              ),
            ]))
    );

  }*/


  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[

          InAppWebView(
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
                useOnDownloadStart: true,
                javaScriptEnabled: true,
                cacheEnabled: true,
              ),
              android: AndroidInAppWebViewOptions(
                disableDefaultErrorPage: true,
                cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
                appCachePath: './Aqui'
              ),
              ios: IOSInAppWebViewOptions(

              )

            ),
            onWebViewCreated: (InAppWebViewController controller) async{
              webView = controller;
              await this.isIndexInitialisable() ? webView.loadUrl(url: indexUrl) : webView.loadData(data: json.decode(await getHTML(storage, indexUrl)));
            },

            shouldOverrideUrlLoading: (controller, request) async {
              return this.doLoadUrl(controller, request);
            },

            onLoadStart: (InAppWebViewController controller, String url) async {
              setLoad();
              showError();
              var connectivityResult = await (Connectivity().checkConnectivity());
              if (connectivityResult == ConnectivityResult.none && await getHTML(storage, url) != null) {
                await controller.loadData(data: json.decode(await getHTML(storage, url)), encoding: 'Base64');
              }
            },

            onLoadStop: (InAppWebViewController controller, String url) async {
              var connectivityResult = await (Connectivity().checkConnectivity());
              if (connectivityResult != ConnectivityResult.none) {
                if(url != "about:blank"){
                  await controller.getHtml().then((value) => {
                    insertStorage(url, storage,value)
                  });
                  stopLoad();
                  hideError();
                }
              }
              String htmlExist = await getHTML(storage, url);
              bool condition = loading && htmlExist != null;
              print("Stop the loader if html exist: $condition, \n$htmlExist");
              if(loading && htmlExist != null){
                Timer(Duration(seconds: 2), () => {
                  hideError()
                });
              }
            },

            onLoadError: (
                InAppWebViewController controller,
                String url,
                int i,
                String s
                ) async {
              showError();
              Timer(Duration(seconds: 2), () => {
                stopLoad()
              });
              this.url = url;
            },

            onLoadHttpError: (InAppWebViewController controller, String url,
                int i, String s) async {
              showError();
              Timer(Duration(seconds: 2), () => {
                stopLoad()
              });
              this.url = url;
            },
          ),

          showErrorPage ?
            Container(
              color: Color(0xFF223A42),
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              child: loading ? Card(
                elevation: 0,
                color: Colors.transparent,
                shadowColor: Colors.transparent,

                child:
                  CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: animationController
                        .drive(RainbowColorTween([Color(0xFFEA5A53), Color(0xFFFABD52), Color(0xFF80BC58)])),
                  )
              ) : Card(
                elevation: 0,
                color: Colors.transparent,
                margin: EdgeInsets.all(20),
                shadowColor: Colors.transparent,
                child: Column(

                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Oups !\n\n",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFFFABD52)),
                        children: <TextSpan> [
                          TextSpan(
                            text: "Cette page n'est pas disponible pour le moment\n",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19, color: Colors.white)
                          ),
                          TextSpan(
                            text: "Veuillez vous connecter à internet afin d'y accéder\n\n",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 19, fontStyle: FontStyle.italic, color: Colors.white)
                          )
                        ]
                      ),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        if (webView != null) {
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.none) {
                            webView.loadUrl(url: this.url);
                            setLoad();
                          }else{
                            Fluttertoast.showToast(
                              msg: "Veuillez vous connecter à internet",
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 1
                            );
                          }
                        }
                      },
                      color: Color(0xFF80BC58),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Rééssayer',
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.refresh,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ) : SizedBox(height: 0, width: 0),

        ]
      ),
    );
  }


  void showError(){
    setState(() {
      this.showErrorPage = true;
    });
  }

  void hideError(){
    setState(() {
      this.showErrorPage = false;
    });
  }

  void setLoad(){
    setState(() {
      this.loading = true;
    });
  }

  void stopLoad(){
    setState(() {
      this.loading = false;
    });
  }


  Future<bool> isIndexInitialisable() async{
    bool initWithUrl = true;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none && await getHTML(this.storage, this.indexUrl) != null) {
      initWithUrl = false;
    }
    return initWithUrl;
  }

  Future<void> readHTML(InAppWebViewController _controller, LocalStorage storage, String url) async {
    await _controller.getHtml().then(
            (value) =>
        {
          if(url != "about:blank" && value != null ){
            this.insertStorage(url, storage, value)
          }
        }
    );
  }


  void insertStorage(String url, LocalStorage storage, String html2) async{
    if(html2 != null && url != "about:blank"){
      JsonCodec json = JsonCodec();
      await storage.setItem(url,json.encode(html2));
      print("Insert $url : " + await storage.getItem(url) );
    }
  }

  Future<String> getHTML(LocalStorage storage, String url) async {
    String html = await storage.getItem(url);
    print("HTML of $url : '$html'");
    return html;
  }

  Future<ShouldOverrideUrlLoadingAction> doLoadUrl(InAppWebViewController controller, ShouldOverrideUrlLoadingRequest request) async{
    String url = request.url;
    if(request.url.startsWith(indexUrl)){
      print(" $url allowed");
      return ShouldOverrideUrlLoadingAction.ALLOW;
    }else{
      print("$url declined");
      await launch(url);
      return ShouldOverrideUrlLoadingAction.CANCEL;
    }
  }
}



