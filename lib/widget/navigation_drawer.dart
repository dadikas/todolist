import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist/pages/home_page.dart';
import 'package:todolist/widget/change_theme_button_widget.dart';
import 'package:todolist/provider/menu_item_provider.dart';

class navigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: Drawer(
              key: Key(Theme.of(context).brightness.toString()),
              backgroundColor: Theme.of(context).primaryColor,
              child: ListView(
                children: [
                  Padding(
                      padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.15)),
                  Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                    
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                  buildMenuItems(context),
                  Padding(
                      padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.35)),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.light_mode_outlined),
                        ChangeThemeButtonWidget(),
                        const Icon(Icons.dark_mode_outlined),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      );

  Widget buildMenuItems(BuildContext context) => Consumer<MenuItemProvider>(
        builder: (context, status, _) => Container(
          padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.06),
          child: Wrap(
            children: [
              ListTile(
                tileColor: status.newStatus == 'task' ? Theme.of(context).iconTheme.color : null,
                horizontalTitleGap: -5,
                leading: const Icon(
                  Icons.event_note_outlined,
                  color: Colors.grey,
                ),
                title: const Text(
                  'Task',
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: -10, horizontal: 10),
                onTap: () {
                  Provider.of<MenuItemProvider>(context, listen: false).changeStatus('task');
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                    (Route<dynamic> route) => false);
                },
              ),

            ],
          ),
        ),
      );
}
