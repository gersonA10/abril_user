import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/functions/providers/sign_in_provider.dart';
import 'package:flutter_user/pages/NavigatorPages/editprofile.dart';
import 'package:flutter_user/pages/NavigatorPages/history.dart';
import 'package:flutter_user/pages/NavigatorPages/makecomplaint.dart';
import 'package:flutter_user/pages/NavigatorPages/outstation.dart';
import 'package:flutter_user/pages/NavigatorPages/settings.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/pages/trip%20screen/map_page.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/widgets.dart';

class UserInfoSheet extends StatefulWidget {
  const UserInfoSheet({super.key});

  @override
  State<UserInfoSheet> createState() => _UserInfoSheetState();
}

class _UserInfoSheetState extends State<UserInfoSheet> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    const Color textColorPrimary = Colors.black87;
    const Color textColorSecondary = Colors.black54;
    const Color surfaceColor = Colors.white;
    final media = MediaQuery.of(context).size;
    final BorderRadius borderRadius = BorderRadius.circular(12);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userDetails['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColorPrimary,
                      ),
                    ),
                    Text(
                      userDetails['mobile'],
                      style: const TextStyle(color: textColorSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: media.width * 0.12,
                  height: media.width * 0.12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                          image: NetworkImage(userDetails['profile_picture']),
                          fit: BoxFit.cover)),
                ),
              ],
            ),
            Divider(height: 32, color: theme),
            ListTile(
              leading:  Icon(Icons.edit, color: theme),
              title: const Text(
                "Editar Perfil",
                style: TextStyle(color: textColorPrimary),
              ),
              onTap: () async {
                var val = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfile()));
                if (val) {
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading:
                   Icon(Icons.view_list_outlined, color: theme),
              title: Text(
                languages[choosenLanguage]['text_enable_history'],
                style: const TextStyle(color: textColorPrimary),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const History()));
              },
            ),
            ListTile(
              leading:  Icon(Icons.luggage_outlined, color: theme),
              title: Text(
                languages[choosenLanguage]['text_outstation'],
                style: const TextStyle(color: textColorPrimary),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OutStationRides()));
              },
            ),
            ListTile(
              leading:  Icon(Icons.warning_amber, color: theme),
              title: Text(
                languages[choosenLanguage]['text_make_complaints'],
                style: const TextStyle(color: textColorPrimary),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MakeComplaint()));
              },
            ),
            ListTile(
              leading:  Icon(Icons.settings, color: theme),
              title: Text(
                languages[choosenLanguage]['text_settings'],
                style: const TextStyle(color: textColorPrimary),
              ),
              onTap: () async {
                var nav = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
                if (nav) {
                  setState(() {});
                }
              },
            ),
            ListTile(
              leading:  Icon(Icons.logout, color: theme),
              title:  Text(
                "Cerrar sesión",
                style: TextStyle(color: theme),
              ),
              onTap: () {
                // setState(() {
                //   logout = true;
                // });
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        languages[choosenLanguage]['text_confirmlogout'],
                        textAlign: TextAlign.center,
                      ),
                      content: Button(
                        onTap: () async {
                          // setState(() {
                          logout = false;
                          _loading = true;
                          // });
                          await SignInProvider().logOut();
                          var result = await userLogout();
                          if (result == 'success' || result == 'logout') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                              (route) => false,
                            );
                            userDetails.clear();
                          } else {
                            // setState(() {
                            _loading = false;
                            logout = true;
                            // });
                          }
                          // setState(() {
                          _loading = false;
                          // });
                        },
                        text: languages[choosenLanguage]['text_confirm'],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
