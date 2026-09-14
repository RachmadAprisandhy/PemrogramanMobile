class LirikLagu {
  String? judul;
  String? penyanyi;
  String? lirik;

  LirikLagu({required this.judul, required this.penyanyi, required this.lirik});

  void tampilkanLirik() {
    print('Judul: $judul');
    print('Penyanyi: $penyanyi');
    print('Lirik: $lirik');
  }
}