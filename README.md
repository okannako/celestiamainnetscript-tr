![(23)](https://github.com/okannako/celestiamainnetscript/assets/73176377/b0c62370-d14b-4046-9feb-6c5cd4e0afc6)

Celestia Mainnet Beta ağında aşağıdaki kodu çalıştırarak Validator, Fibre, Bridge ve Light Node kurabilirsiniz. Script güncel sürümlere göre hazırlanmıştır (celestia-app v10.5.0, celestia-node v0.34.4). Diğer ayrıntılarla birlikte bu script sayesinde kurulumu çok kısa bir süre içerisinde yapabilirsiniz.

NOT: Full Storage Node tipi celestia-node'dan kaldırıldı. Bütün veriyi tutmak isteyenler Bridge Node'u --archival ile çalıştırabilir.

```
curl -s https://raw.githubusercontent.com/okannako/celestiamainnetscript/main/nodescript.sh > nodescript.sh && chmod +x nodescript.sh && ./nodescript.sh
```

### bbr Aktif Hale Getirmek (Mutlaka Yapın)
- Validator kurulumunda script bunu otomatik yapar. Bridge veya Light Node kurduysanız ya da kontrol etmek isterseniz aşağıdaki kodları girebilirsiniz.
```
cd $HOME/celestia-app
make bbr-enable
make bbr-check
```

- Eğer yukarıdaki kodlarda hata alırsanız aşağıdaki kodla aktif hale getirebilirsiniz.
```
sudo modprobe tcp_bbr
echo “net.core.default_qdisc=fq” | sudo tee -a /etc/sysctl.conf
echo “net.ipv4.tcp_congestion_control=bbr” | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

- Aktiflik kontrolünü aşağıdaki kodla yaptığınızda sonuç olarak `bbr` vermelidir.
