import 'package:flutter/material.dart';
import 'package:instagram_flutter_clone/screens/feed_screen.dart';
import 'package:instagram_flutter_clone/screens/explore_screen.dart';
import 'package:instagram_flutter_clone/screens/profile_screen.dart';

const homeScreenItems = [
  FeedScreen(),
  ExploreScreen(),
  Center(child: Text('Add Post', style: TextStyle(color: Colors.white))),
  Center(child: Text('Favorite', style: TextStyle(color: Colors.white))),
  ProfileScreen(),
];
