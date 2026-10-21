# Mini SystemVerilog Veri Yolu

SystemVerilog ile yazılmış küçük bir eğitim amaçlı veri yolu tasarımıdır. 4-bit register file, basit bir komut çözücü ve ALU’yu bir araya getirerek dışarıdan verilen komutları sırayla çalıştırır.

Bu proje tam bir CPU değildir: program sayacı, komut belleği ve dallanma mantığı içermez. Kullanılan 12-bit komut biçimi bu proje için özel olarak tanımlanmıştır; RISC-V komut kodlaması değildir.

## Özellikler

- Dört adet 4-bit register (`R0`–`R3`)
- İki kombinasyonel okuma portu ve clock ile çalışan bir yazma portu
- Aktif yüksek asenkron reset
- `ADD`, `SUB` ve `ADDI` işlemleri
- `zero` çıkış bayrağı
- Aritmetiği, register’a yazmayı ve `zero` bayrağını kontrol eden testbench

## Komut biçimi

| Bitler | Alan |
| --- | --- |
| `[11:10]` | Opcode |
| `[9:8]` | Hedef register (`rd`) |
| `[7:6]` | Birinci kaynak register (`rs1`) |
| `[5:4]` | İkinci kaynak register (`rs2`) |
| `[3:0]` | 4-bit sabit değer (immediate) |

| Opcode | İşlem | Sonuç |
| --- | --- | --- |
| `2'b00` | `ADD rd, rs1, rs2` | `R[rd] = R[rs1] + R[rs2]` |
| `2'b01` | `SUB rd, rs1, rs2` | `R[rd] = R[rs1] - R[rs2]` |
| `2'b10` | `ADDI rd, rs1, imm` | `R[rd] = R[rs1] + imm` |
| `2'b11` | İşlem yok | Register’a yazılmaz |

Sonuç 4 bit olduğu için taşan bit atılır; aritmetik mod 16’ya göre sonuçlanır. `ADDI` işleminde `rs2` alanı kullanılmaz.

## Dosyalar

- `design.sv` — veri yolu tasarım modülü
- `testbench.sv` — clock ve reset üretimi ile komutları kontrol eden testbench

## Simülasyonu çalıştırma

Icarus Verilog kuruluysa bu klasörde şu komutları çalıştır:

```sh
iverilog -g2012 -s tb -o sim design.sv testbench.sv
vvp sim
```

Her kontrol başarılı olursa testbench `PASS` mesajlarını ve sonunda tüm kontrollerin tamamlandığını yazdırır.
