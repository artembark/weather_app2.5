import 'package:flutter/material.dart';

class CityList extends StatefulWidget {
  @override
  _CityListState createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  List<String> cities = [
    'Москва',
    'Приозерск',
    'Уфа',
    'Новосибирск',
    'Токио',
    'Париж',
    'Берлин',
    'Таллин'
  ];
  var city = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выберите город'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 17),
              hintText: 'Введите город',
              suffixIcon: GestureDetector(
                child: Icon(Icons.search),
                onTap: () {
                  Navigator.pop(context, city);
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(30),
            ),
            onChanged: (text) {
              city = text;
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.pop(context, cities[index]);
                  },
                  title: Text(cities[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
