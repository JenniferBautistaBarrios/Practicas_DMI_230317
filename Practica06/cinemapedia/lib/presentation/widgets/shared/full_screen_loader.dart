import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/widgets/shared/cinemapedia_logo.dart';


class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});
  
  Stream<String> getLoadingMessages( List<String> messages ) {
    return Stream.periodic( const Duration(milliseconds: 1200), (step) {
      return messages[step];
    }).take(messages.length);
  }


  @override
  Widget build(BuildContext context) {

    final t = AppStrings.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Pulse(
            infinite: true,
            duration: const Duration(milliseconds: 1400),
            child: const CinemapediaLogo(size: 72),
          ),
          const SizedBox(height: 20),
          Text(t.pleaseWait),
          const SizedBox(height: 10),

          StreamBuilder(
            stream: getLoadingMessages( t.loadingMessages ),
            builder: (context, snapshot) {
              if ( !snapshot.hasData ) return Text(t.loading);
              
              return Text( snapshot.data! );
            },
          ),
        ],
      ),
    );
  }
}
