import 'package:all_booked/View/screens/add_friend_screen.dart';
import 'package:all_booked/ViewModel/friends/friends_bloc.dart';
import 'package:all_booked/ViewModel/friends/friends_event.dart';
import 'package:all_booked/ViewModel/friends/friends_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

class FriendsScreen extends StatelessWidget {
  final FriendBloc friendBloc = FriendBloc();

  static const String routeName = '/friends';

  FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF000000)
            : Color(0xFFF2F2F7),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Prieteni"),
          actions: [
            IconButton(
              icon: Icon(
                CupertinoIcons.add_circled_solid,
                size: 26,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : Theme.of(context).primaryColor.withOpacity(0.7),
              ),
              padding: EdgeInsets.all(8),
              onPressed: () {
                context.push(AddFriendScreen.routeName);
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Lista"),
              Tab(text: "Cereri"),
            ],
          ),
        ),
        body: BlocProvider(
          create: (_) => friendBloc..add(LoadFriends()),
          child: TabBarView(
            children: [
              _buildFriendsList(),
              _buildFriendRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FriendsLoaded) {
          final acceptedFriends = state.friends
              .where((friend) => friend['status'] == 'accepted')
              .toList();

          if (acceptedFriends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 84,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "Nu ai niciun prieten încă",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Adaugă prieteni pentru a împărtăși cărți",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: acceptedFriends.length,
            itemBuilder: (context, index) {
              final friend = acceptedFriends[index];
              final String name = friend['name'] ?? 'Necunoscut';
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF1C1C1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: CupertinoListTile(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.transparent,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: friend['image_url'] != null
                        ? NetworkImage(friend['image_url'])
                        : null,
                    child: friend['image_url'] == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    friend['email'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 20,
                      color: CupertinoColors.systemGrey,
                    ),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          actions: [
                            CupertinoActionSheetAction(
                              isDestructiveAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CupertinoAlertDialog(
                                    title: Text('Șterge prieten'),
                                    content: Text(
                                      'Ești sigur că vrei să ștergi acest prieten? Această acțiune nu poate fi anulată.',
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text('Anulează'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        child: Text('Șterge'),
                                        onPressed: () {
                                          context
                                              .read<FriendBloc>()
                                              .add(DeleteFriend(friend['id']));
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Șterge prieten'),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('Anulează'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        } else if (state is FriendError) {
          return Center(child: Text(state.message));
        }
        return Center(child: Text("Nu s-au găsit prieteni"));
      },
    );
  }

  Widget _buildFriendRequests() {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state is FriendsLoading) {
          return Center(child: CupertinoActivityIndicator());
        } else if (state is FriendsLoaded) {
          final pendingRequests = state.friends
              .where((friend) => friend['status'] == 'pending')
              .toList();

          if (pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.mail_solid,
                      size: 84,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]
                          : Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "Nu ai cereri de prietenie noi",
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Vei vedea aici când cineva îți trimite o cerere",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final String name = request['name'] ?? 'Necunoscut';
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF1C1C1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: CupertinoListTile(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.transparent,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: request['image_url'] != null
                        ? NetworkImage(request['image_url'])
                        : null,
                    child: request['image_url'] == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    request['email'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: CupertinoColors.activeGreen,
                          size: 24,
                        ),
                        onPressed: () {
                          context
                              .read<FriendBloc>()
                              .add(AcceptFriendRequest(request['id'] ?? ''));
                        },
                      ),
                      SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.xmark_circle,
                          color: CupertinoColors.destructiveRed,
                          size: 24,
                        ),
                        onPressed: () {
                          context
                              .read<FriendBloc>()
                              .add(RejectFriendRequest(request['id'] ?? ''));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}
