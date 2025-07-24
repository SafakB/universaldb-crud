# UniversalDB CRUD API - Docker Setup

Bu proje PHP-CRUD-API kullanarak geliştirilmiş bir RESTful API'dir ve Docker ile kolayca çalıştırılabilir.

## Gereksinimler

- Docker
- Docker Compose

## Kurulum ve Çalıştırma

### 1. Projeyi klonlayın veya indirin

```bash
git clone <repository-url>
cd universaldb-crud2
```

### 2. Docker konteynerlerini başlatın

```bash
docker-compose up -d
```

Bu komut şunları başlatacak:
- **Web Server**: PHP-CRUD-API (Port: 8080)
- **MySQL Database**: Veritabanı sunucusu (Port: 3306)
- **phpMyAdmin**: Veritabanı yönetim arayüzü (Port: 8081)

### 3. Servislere erişim

- **API Endpoint**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081
  - Kullanıcı: `root`
  - Şifre: `rootpassword`

## API Kullanımı

### Durum Kontrolü
```bash
curl http://localhost:8080/status
```

### API Key ile Kimlik Doğrulama
```bash
curl -H "X-API-Key: your-secret-api-key-1" http://localhost:8080/status
```

### Kategorileri Listeleme
```bash
curl -H "X-API-Key: your-secret-api-key-1" http://localhost:8080/records/categories
```

### Filtreleme
```bash
curl -H "X-API-Key: your-secret-api-key-1" "http://localhost:8080/records/categories?filter=name,eq,Technology"
```

### Makale Ekleme
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-secret-api-key-1" \
  -d '{"title":"Yeni Makale","content":"Makale içeriği","category_id":1,"author":"Yazar Adı","published":true}' \
  http://localhost:8080/records/articles
```

## JWT Kimlik Doğrulama

### JWT Token Alma
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password123"}' \
  http://localhost:8080/login
```

### JWT ile API Kullanımı
```bash
curl -H "X-Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:8080/records/articles
```

## Veritabanı Yapısı

Proje başlatıldığında otomatik olarak şu tablolar oluşturulur:

- **categories**: Kategori bilgileri
- **articles**: Makale bilgileri
- **users**: Kullanıcı bilgileri (kimlik doğrulama için)

## Geliştirme

### Logları İzleme
```bash
docker-compose logs -f web
```

### Konteyner İçine Erişim
```bash
docker-compose exec web bash
```

### Veritabanına Erişim
```bash
docker-compose exec db mysql -u root -p universaldb
```

## Durdurma ve Temizleme

### Servisleri Durdurma
```bash
docker-compose down
```

### Verileri de Silme
```bash
docker-compose down -v
```

## Konfigürasyon

- **API ayarları**: `.env` dosyasında
- **Veritabanı başlangıç verileri**: `init.sql` dosyasında
- **Docker ayarları**: `docker-compose.yml` dosyasında

## Güvenlik Notları

- Üretim ortamında `.env` dosyasındaki şifreleri değiştirin
- API anahtarlarını güvenli tutun
- JWT secret anahtarını güçlü bir değerle değiştirin
- Gerekirse CORS ayarlarını yapılandırın

## Sorun Giderme

### Port Çakışması
Eğer portlar kullanımdaysa, `docker-compose.yml` dosyasında port numaralarını değiştirin.

### Veritabanı Bağlantı Sorunu
Konteynerler arası iletişim için `.env` dosyasında `DB_ADDRESS=db` olarak ayarlandığından emin olun.

### Composer Bağımlılıkları
Eğer yeni paket eklerseniz:
```bash
docker-compose exec web composer install
```