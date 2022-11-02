import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twilio_voice_mimp/twilio_voice.dart';

import '../util/formatter.dart';

class CallingScreen extends StatefulWidget {
  final String caller;
  const CallingScreen({super.key, required this.caller});

  @override
  CallingScreenState createState() => CallingScreenState();

  static Future<bool?> dialCustomer(String phoneNumber) async {
    String tel = FormatterUtil.phoneNumberToIntlFormat(phoneNumber);
    return TwilioVoice.instance.hasMicAccess().then((hasMicAccess) {
      if (!hasMicAccess) {
        TwilioVoice.instance.requestMicAccess().then((micAccessRequested) {
          if (true == micAccessRequested) {
            return TwilioVoice.instance.call.place(to: tel, from: '+32460230233');
          }
          return false;
        });
      }
      return TwilioVoice.instance.call.place(to: tel, from: '+32460230233');
    });
  }
}

class CallingScreenState extends State<CallingScreen> {
  var speaker = false;
  var mute = false;
  var isEnded = false;

  String? message = "Connecting...";
  late StreamSubscription<CallEvent> callStateListener;

  void listenCall() {
    callStateListener = TwilioVoice.instance.callEventsListener.listen((event) {
      switch (event) {
        case CallEvent.callEnded:
          if (!isEnded) {
            isEnded = true;
            Navigator.of(context).pop();
          }
          break;
        case CallEvent.mute:
          setState(() => mute = true);
          break;
        case CallEvent.connected:
          setState(() => message = "Connected!");
          break;
        case CallEvent.unmute:
          setState(() => mute = false);
          break;
        case CallEvent.speakerOn:
          setState(() => speaker = true);
          break;
        case CallEvent.speakerOff:
          setState(() => speaker = false);
          break;
        case CallEvent.ringing:
          setState(() => message = "Calling...");
          break;
        case CallEvent.answer:
          setState(() => message = null);
          break;
        case CallEvent.hold:
        case CallEvent.log:
        case CallEvent.unhold:
          break;
        default:
          break;
      }
    });
  }

  @override
  void initState() {
    listenCall();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    callStateListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      widget.caller,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    if (message != null)
                      Text(
                        message!,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Colors.white),
                      )
                  ],
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Material(
                        type: MaterialType
                            .transparency, //Makes it usable on any background color, thanks @IanSmith
                        child: Ink(
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.white, width: 1.0),
                            color: speaker
                                ? Theme.of(context).primaryColor
                                : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            //This keeps the splash effect within the circle
                            borderRadius: BorderRadius.circular(
                                1000.0), //Something large to ensure a circle
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Icon(
                                Icons.volume_up,
                                size: 40.0,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              // setState(() {
                              //   speaker = !speaker;
                              // });
                              TwilioVoice.instance.call.toggleSpeaker(!speaker);
                            },
                          ),
                        ),
                      ),
                      Material(
                        type: MaterialType
                            .transparency, //Makes it usable on any background color, thanks @IanSmith
                        child: Ink(
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.white, width: 1.0),
                            color: mute
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            //This keeps the splash effect within the circle
                            borderRadius: BorderRadius.circular(
                                1000.0), //Something large to ensure a circle
                            child: const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Icon(
                                Icons.mic_off,
                                size: 40.0,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              TwilioVoice.instance.call.toggleMute(!mute);
                              // setState(() {
                              //   mute = !mute;
                              // });
                            },
                          ),
                        ),
                      )
                    ]),
                RawMaterialButton(
                  elevation: 2.0,
                  fillColor: Colors.red,
                  padding: const EdgeInsets.all(20.0),
                  shape: const CircleBorder(),
                  onPressed: () async {
                    final isOnCall =
                    await TwilioVoice.instance.call.isOnCall();
                    if (isOnCall) {
                      TwilioVoice.instance.call.hangUp();
                    }
                  },
                  child: const Icon(
                    Icons.call_end,
                    size: 40.0,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}