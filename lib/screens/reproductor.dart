
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import '../models/pop.dart';
import '../providers/pop_provider.dart';

class ReproductorPops extends StatefulWidget {
  @override
 createState() => _ReproductorPopsState();
}

class _ReproductorPopsState extends State<ReproductorPops> {

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override 
  void initState(){
    super.initState();

    setAudio();

    audioPlayer.onPlayerStateChanged.listen((state){
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    }); 

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
     });

     audioPlayer.onAudioPositionChanged.listen((newPosition) {
       setState(() {
         position = newPosition;
       });
      });
  }

  Future setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    final player = AudioCache(prefix: "assets/");
    final url = await player.load("SMHTL.mp3");
    audioPlayer.setUrl(url.path, isLocal: true);
  }


  @override 
  void dispose(){
    audioPlayer.dispose();

    super.dispose();
  } 

  
  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(":");
  }

  @override
  Widget build(BuildContext context){
    final popProvider = Provider.of<PopProvider>(context);
    final List<Pop> listaPops = popProvider.listaPops;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:Swiper(
                itemCount: listaPops.length,
                layout: SwiperLayout.STACK,
                itemWidth: size.width * 0.5,
                itemHeight: size.height * 0.6,
                itemBuilder: (BuildContext context, int index){
                return _cardPops(listaPops[index]);
                },
              )),
              Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await audioPlayer.seek(position);

                  await audioPlayer.resume(); 
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatTime(position)),
                    Text(formatTime(duration - position)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 35,
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  iconSize: 50,
                  onPressed: () async {
                    if (isPlaying) {
                      await audioPlayer.pause();
                    }else{
                      await audioPlayer.resume();
                    }
                  },
                ),
              )
            ]
          ))
      );
    }
  }

class _cardPops extends StatelessWidget{
  final Pop reproductorPops;
  _cardPops(this.reproductorPops);
  @override 
  Widget build(BuildContext context) {

  final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(top: 90, bottom: 20),
      width: double.infinity,
      height: size.height * 0.5,
      decoration: _cardBorders(),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children:[_ImagenFondo(reproductorPops), _Info(reproductorPops)],
    )
    );
  }
  BoxDecoration _cardBorders() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        offset: Offset(0,7),
        blurRadius: 10
      )
    ]
  );
}

class _ImagenFondo extends StatelessWidget {
  final Pop reproductorPops;
  _ImagenFondo(this.reproductorPops);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 300,
        child: FadeInImage(
            placeholder: AssetImage('assets/jar-loading.gif'),
            image: NetworkImage(reproductorPops.portada),
            fit: BoxFit.cover),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Pop reproductorPops;
  _Info(this.reproductorPops);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25)),
          color: Colors.grey),
      child: ListTile(
        title: Text(
          reproductorPops.cancion,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
        reproductorPops.banda.toString(),
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}