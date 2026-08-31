import 'LuasPersegiPanjang.dart';
import 'ProfilMahasiswa.dart';
void main(){
  double hasil = persegi_panjang(10, 5);
  print("Luas Persegi Panjang: $hasil");

  String Profil = ProfilMahasiswa("Fulan", "082222222", "Fulan@gmail.com");
  print(Profil);
}