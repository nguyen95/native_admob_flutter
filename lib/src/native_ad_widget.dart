import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'layout_builder/layout_builder.dart';
import 'utils.dart';
import 'controller.dart';

const _viewType = "native_admob";

class NativeAd extends StatefulWidget {
  /// How the views should be presented to the user.
  ///
  /// Use [adBannerLayoutBuilder] as a default banner layout
  ///
  /// Hot reload does NOT work while building an ad layout
  final AdLayoutBuilder buildLayout;

  /// The rating bar. This isn't always inclued in the request
  final AdRatingBarView ratingBar;

  /// The full media view. This is always included in the request
  final AdMediaView media;

  /// The icon view. This isn't always inclued in the request
  final AdImageView icon;

  /// The ad headline. This is always inclued in the request
  final AdTextView headline;

  /// The ad advertiser. This isn't always inclued in the request
  final AdTextView advertiser;

  /// The ad body. This isn't always inclued in the request
  final AdTextView body;

  /// The app price. This isn't always inclued in the request
  final AdTextView price;

  /// The store. This isn't always inclued in the request
  final AdTextView store;

  /// The ad attribution. This is always inclued in the request
  final AdTextView attribution;

  /// The ad button. This isn't always inclued in the request
  final AdButtonView button;

  /// The ad controller. If not specified, uses a default controller
  final NativeAdController controller;

  /// The widget used in case an error shows up
  final Widget error;

  /// The widget used when the ad is loading.
  final Widget loading;

  /// The height of the ad. If this is null, the widget will expand
  ///
  /// 🔴IMPORTANT❗🔴:
  /// Ad views that have a width or height smaller than 32 will be
  /// demonetized in the future.
  /// Please make sure the ad view has sufficiently large area.
  ///
  /// Usage inside of a Column requires an Expanded or a defined height.
  /// Usage inside of a ListView requires a defined height.
  final double height;

  /// The width of the ad. If this is null, the widget will expand
  ///
  /// 🔴IMPORTANT❗🔴:
  /// Ad views that have a width or height smaller than 32 will be
  /// demonetized in the future.
  /// Please make sure the ad view has sufficiently large area.
  ///
  /// Usage inside of a Row requires an Expanded or a defined width.
  /// Usage inside of a ListView requires a defined width.
  final double width;

  NativeAd({
    Key key,
    @required this.buildLayout,
    this.advertiser,
    this.attribution,
    this.body,
    this.button,
    this.headline,
    this.icon,
    this.media,
    this.price,
    this.ratingBar,
    this.store,
    this.controller,
    this.error,
    this.loading,
    this.height,
    this.width,
  })  : assert(buildLayout != null),
        super(key: key);

  @override
  _NativeAdState createState() => _NativeAdState();
}

class _NativeAdState extends State<NativeAd>
    with AutomaticKeepAliveClientMixin {
  NativeAdController controller;

  AdEvent state = AdEvent.loading;

  @override
  void didUpdateWidget(NativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.requestAdUIUpdate(layout);
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? NativeAdController();
    controller.load();
    controller.onEvent.listen((e) {
      final event = e.keys.first;
      switch (event) {
        case AdEvent.loading:
        case AdEvent.loaded:
        case AdEvent.loadFailed:
          setState(() => state = event);
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Google Native ads are only supported in Android and iOS
    assert(
      Platform.isAndroid || Platform.isIOS,
      'The current platform does not support native ads. The platforms that support it are Android and iOS',
    );

    assert(
        Platform.isAndroid, 'Android is the only supported platform for now');

    if (state == AdEvent.loading) return widget.loading ?? SizedBox();

    if (state == AdEvent.loadFailed) return widget.error ?? SizedBox();

    Widget w;

    if (Platform.isAndroid) {
      w = AndroidView(
        viewType: _viewType,
        creationParamsCodec: StandardMessageCodec(),
        creationParams: layout,
      );
      // } else if (Platform.isIOS) {
      //   w = UiKitView(
      //     viewType: _viewType,
      //     creationParamsCodec: StandardMessageCodec(),
      //     creationParams: layout,
      //   );
    } else {
      return SizedBox();
    }

    if (widget.height != null)
      assert(
        widget.height > 32,
        '''
        Ad views that have a width or height smaller than 32 will be demonetized in the future. 
        Please make sure the ad view has sufficiently large area.
        ''',
      );

    if (widget.width != null)
      assert(
        widget.height > 32,
        '''
        Ad views that have a width or height smaller than 32 will be demonetized in the future. 
        Please make sure the ad view has sufficiently large area.
        ''',
      );

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: w,
    );
  }

  Map<String, dynamic> get layout {
    // default the layout views
    final headline = widget.headline ??
        AdTextView(
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          maxLines: 1,
        );
    final advertiser = widget.advertiser ?? AdTextView();
    BorderRadius.vertical();
    final attribution = widget.attribution ??
        AdTextView(
          width: WRAP_CONTENT,
          height: WRAP_CONTENT,
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          backgroundColor: Colors.yellow,
          text: 'Ad',
          margin: EdgeInsets.only(right: 2),
          maxLines: 1,
          borderRadius: AdBorderRadius.all(10),
        );
    final body = widget.body ?? AdTextView();
    final button = widget.button ??
        AdButtonView(
          backgroundColor: Colors.yellow,
          pressColor: Colors.yellowAccent,
          margin: EdgeInsets.all(6),
          borderRadius: AdBorderRadius.vertical(bottom: 10),
        );
    final icon = widget.icon ??
        AdImageView(
          margin: EdgeInsets.only(right: 4),
        );
    final media = widget.media ?? AdMediaView();
    final price = widget.price ?? AdTextView();
    final ratingBar = widget.ratingBar ?? AdRatingBarView();
    final store = widget.store ?? AdTextView();

    // define the layout ids
    advertiser.id = 'advertiser';
    attribution.id = 'attribution';
    body.id = 'body';
    button.id = 'button';
    headline.id = 'headline';
    icon.id = 'icon';
    media.id = 'media';
    price.id = 'price';
    ratingBar.id = 'ratingBar';
    store.id = 'store';

    // build the layout
    final layout = (widget.buildLayout ?? adBannerLayoutBuilder)
        .call(
          ratingBar,
          media,
          icon,
          headline,
          advertiser,
          body,
          price,
          store,
          attribution,
          button,
        )
        ?.toJson();

    layout.addAll({'controllerId': controller.id});

    assert(layout != null, 'The layout must not return null');
    return layout;
  }

  @override
  bool get wantKeepAlive => true;
}