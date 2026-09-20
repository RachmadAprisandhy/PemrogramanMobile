class Mahasiswa {
  String? nama;
  String? umur;
  String?kelas;

  Mahasiswa ({required this.nama, required this.umur, required this.kelas});

  void tampilkanProfil() {
    print('Nama: $nama');
    print('Umur: $umur');
    print('Kelas: $kelas');
  }
}