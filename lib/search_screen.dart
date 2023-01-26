import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget{
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const _CustomAppBar(),
        body: SingleChildScrollView(
          child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Text(
                  //   'Hi,    start    listening!',
                  //   style: TextStyle(
                  //     color: Color(0xffffffff),
                  //   ),
                  // ),
                  const SizedBox(height: 5),
                  const SizedBox(height: 15),

                  Stack(
                  children:[
                    Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset("assets/icons/searchbox.png"),
                  ),
                  TextFormField(
                    style: const TextStyle(
                      fontFamily: 'Persona',
                      color: Color(0xffffffff)
                      ),
                    decoration:
                     const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 38),
                      fillColor: Color.fromARGB(0, 0, 0, 0),
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 13,    
                        ),
                      // hintStyle: Theme.of(context).textTheme.bodyMedium.copyWith
                    ), 
                  ),
                  
                  ]
                  )
                ],
              ),
            )
          ],)
          ),
      );
    
  }
}



class _CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const _CustomAppBar({
    Key? key,
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Image.asset("assets/icons/logo.png",),
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(56);
}
