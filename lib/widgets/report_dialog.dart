import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovenation_flutter/constants/strings.dart';
import 'package:groovenation_flutter/cubit/social_cubit.dart';
import 'package:groovenation_flutter/models/social_person.dart';
import 'package:groovenation_flutter/models/social_post.dart';

class ReportDialog extends StatefulWidget {
  final SocialPerson _person;
  final SocialPost _post;

  ReportDialog(this._person, this._post);

  @override
  _ReportDialogPageState createState() =>
      _ReportDialogPageState(_person, _post);
}

class _ReportDialogPageState extends State<ReportDialog> {
  OutlineInputBorder textBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.white.withOpacity(0.4)));
  final SocialPerson _person;
  final SocialPost _post;

  _ReportDialogPageState(this._person, this._post);

  final List<String> items = <String>[
    REPORT_REASON_SPAM,
    REPORT_REASON_NUDITY,
    REPORT_REASON_HATE_SPEECH,
    REPORT_REASON_VIOLENCE,
    REPORT_REASON_SALE_OF_ILLEGAL_GOODS,
    REPORT_REASON_BULLYING,
    REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION,
    REPORT_REASON_SUICIDE,
    REPORT_REASON_EATING_DISORDERS,
    REPORT_REASON_SCAM,
    REPORT_REASON_FALSE_INFORMATION,
    REPORT_REASON_OTHER,
  ];

  String dropdownValue = REPORT_REASON_SPAM;

  final textController = TextEditingController();

  String getCurrentValue(String input) {
    switch (input) {
      case REPORT_REASON_SPAM:
        return REPORT_REASON_SPAM_PROMPT;
        break;
      case REPORT_REASON_NUDITY:
        return REPORT_REASON_NUDITY_PROMPT;
        break;
      case REPORT_REASON_HATE_SPEECH:
        return REPORT_REASON_HATE_SPEECH_PROMPT;
        break;
      case REPORT_REASON_VIOLENCE:
        return REPORT_REASON_VIOLENCE_PROMPT;
        break;
      case REPORT_REASON_SALE_OF_ILLEGAL_GOODS:
        return REPORT_REASON_SALE_OF_ILLEGAL_GOODS_PROMPT;
        break;
      case REPORT_REASON_BULLYING:
        return REPORT_REASON_BULLYING_PROMPT;
        break;
      case REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION:
        return REPORT_REASON_INTELLECTUAL_PROPERTY_VIOLATION_PROMPT;
        break;
      case REPORT_REASON_SUICIDE:
        return REPORT_REASON_SUICIDE_PROMPT;
        break;
      case REPORT_REASON_EATING_DISORDERS:
        return REPORT_REASON_EATING_DISORDERS_PROMPT;
        break;
      case REPORT_REASON_SCAM:
        return REPORT_REASON_SCAM_PROMPT;
        break;
      case REPORT_REASON_FALSE_INFORMATION:
        return REPORT_REASON_FALSE_INFORMATION_PROMPT;
        break;
      case REPORT_REASON_OTHER:
        return REPORT_REASON_OTHER_PROMPT;
        break;
      default:
        return REPORT_REASON_SPAM_PROMPT;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(
            insetPadding: EdgeInsets.all(16),
            backgroundColor: Colors.purple,
            contentPadding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _post == null ? "Report User" : "Report Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'LatoBold',
                          ),
                        ),
                      ),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon:
                              Icon(Icons.close, color: Colors.white, size: 28)),
                    ]),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "Why are you reporting?",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.4)),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(
                      top: 16,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.0, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Stack(
                        children: [
                          DropdownButton<String>(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            iconSize: 28,
                            elevation: 16,
                            style: TextStyle(color: Colors.deepPurple),
                            isExpanded: true,
                            underline: Container(
                              height: 0,
                              color: Colors.transparent,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                              });
                            },
                            itemHeight: 56,
                            value: null,
                            items: items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(getCurrentValue(value),
                                    style: TextStyle(
                                        fontFamily: 'Lato',
                                        color: Colors.deepPurple,
                                        fontSize: 18)),
                              );
                            }).toList(),
                          ),
                          Container(
                            height: 56,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                getCurrentValue(dropdownValue),
                                style: TextStyle(
                                    fontFamily: 'Lato',
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "Any additional comments on the issue? (Optional)",
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.4)),
                  ),
                ),
                SizedBox(
                    height: 156,
                    child: Container(
                        height: double.infinity,
                        child: TextField(
                          controller: textController,
                          keyboardType: TextInputType.multiline,
                          autofocus: false,
                          maxLines: null,
                          minLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          cursorColor: Colors.white.withOpacity(0.7),
                          style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                              fontSize: 20),
                          decoration: InputDecoration(
                              border: textBorder,
                              focusedBorder: textBorder,
                              enabledBorder: textBorder,
                              errorBorder: textBorder,
                              disabledBorder: textBorder,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              hintText: "Type here",
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.3))),
                        ))),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  child: TextButton(
                    onPressed: () {
                      final UserSocialCubit userSocialCubit =
                          BlocProvider.of<UserSocialCubit>(context);

                      FocusScope.of(context).unfocus();

                      userSocialCubit.sendReport(
                          dropdownValue, textController.text, _post, _person);

                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ))),
                    child: Padding(
                      padding: EdgeInsets.only(top: 12, bottom: 12),
                      child: Center(
                          child: Text(
                        "Send Report",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      )),
                    ),
                  ),
                ),
              ]),
            ]));
  }
}
