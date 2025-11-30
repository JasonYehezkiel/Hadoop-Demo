# Data Warehouse Modeling

Proyek ini menunjukan demo **data warehouse (DW) modeling** menggunakan **Docker**, **HDFS**, **Hive**, **Hadoop**, dan file **Parquet**. Proyek ini mencakup tabel **dimensions** dan **facts** yang disimpan dalam format Parquet dan dapat di-query menggunakan hive.

## 📋 Daftar Isi

- [Arsitektur](#🏗️-arsitektur)
- [Struktur Folder](#📁-struktur-folder)
- [Prerequisites](#🔧-prerequisites)
- [Setup dan Instalasi](#🚀-setup-dan-instalasi)
- [Penggunaan](#🗄️-penggunaan)
- [Dimensional Model](#dimensional-model)

---

## 🏗️ Arsitektur

Proyek ini mengimplementasikan arsitektur **Data Lake** dengan komponen berikut:

```
┌─────────────────────────────────────────────────────────┐
│                     Docker Compose                      │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   NameNode   │  │  DataNode    │  │ Hive Server  │   │
│  │   (Master)   │  │  (Worker)    │  │              │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│                                                         │
│            ┌──────────────┐  ┌──────────────┐           │
│            │ Hive         │  │ PostgreSQL   │           │
│            │ Metastore    │  │ (Metadata)   │           │
│            └──────────────┘  └──────────────┘           │
└─────────────────────────────────────────────────────────┘
                            ▼
                ┌──────────────────────┐
                │  HDFS Storage Layer  │
                │  (Parquet Files)     │
                └──────────────────────┘
```
**Komponen:**
- **NameNode** - HDFS master node (mengelola metadata file system)
- **DataNode** - HDFS worker node (menyimpan data blocks)
- **Hive Server** - SQL query engine untuk data warehouse
- **Hive Metastore** - Service untuk mengelola metadata tabel Hive
- **PostgreSQL** - Database backend untuk Hive metastore
- **Parquet** - Columnar storage format (efisien & terkompresi)

---

## 📁 Struktur Folder

```text
dw_modeling/
├── docker-compose.yml
├── hadoop.env
├── create_tables.hql
├── demo_queries.hql
├── init-metastore.sh
├── README.md
└── data/
    ├── dimensions/
    │   ├── dim_date.parquet
    │   ├── dim_store.parquet
    │   ├── dim_product.parquet
    │   ├── dim_supplier.parquet
    │   ├── dim_customer.parquet
    │   ├── dim_cashier.parquet
    │   └── dim_payment.parquet
    └── facts/
        ├── fact_sales.parquet
        ├── fact_daily_sales.parquet
        ├── fact_store_performance.parquet
        ├── fact_product_performance.parquet
        ├── fact_store_daily_balance.parquet
        ├── fact_product_daily_movement.parquet
        ├── fact_customer_daily_activity.parquet
        ├── fact_promo_coverage.parquet
        ├── fact_product_availability.parquet
        ├── fact_daily_snapshot.parquet
        ├── fact_store_snapshot.parquet
        ├── fact_customer_accumulation.parquet
        └── fact_store_accumulation.parquet
└── sources/
     ├── retail_transactions.csv
     └── retail_transactions.parquet
```

- **data/dimensions/** – tabel dimensi dalam format Parquet  
- **data/facts/** – tabel fakta dalam format Parquet  
- **docker-compose.yml** – mendefinisikan container Hadoop HDFS, Hive, dan MySQL (opsional)  
- **hadoop.env** – variabel lingkungan untuk container Hadoop  
- **create_tables.mysql** – skrip MySQL opsional untuk metastore eksternal  
- **demo_queries.mysql** – contoh query untuk testing  

---

## 🔧 Prerequisites

Pastikan sudah terinstall:
- **Docker Desktop** (untuk Windows/Mac) atau **Docker Engine** (untuk Linux)
- **Docker Compose** (biasanya sudah include di Docker Desktop)
- Minimal **4GB RAM** available untuk containers
- **5GB disk space** untuk images dan data

Verifikasi instalasi:
```powershell
docker --version
docker-compose --version
```
---

## 🚀 Setup dan Instalasi

### **Langkah 1: Clone/Download Proyek**
```powershell
cd C:\
mkdir dw_modeling
cd dw_modeling
```

Pastikan struktur folder dan file sudah sesuai dengan [Struktur Folder](#-struktur-folder) di atas.

### **Langkah 2: Start Hadoop Cluster**
```powershell
docker-compose up -d
```

**Tunggu 2-3 menit** untuk semua services selesai starting up.

Verifikasi semua container berjalan:
```powershell
docker-compose ps
```
Container yang diharapkan:
- **hive-metastore**
- **hive-server**
- **namenode** 
- **datanode**
- **hive-metastore-postgresql**

## 📤 Upload Data ke HDFS

### **Langkah 3: Buat Struktur Direktori HDFS**
```powershell
# Buat base directories
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts

# Set permissions
docker exec -it namenode hdfs dfs -chmod -R 777 /user/datalake
```

## **Langkah 4: Buat Subdirectories untuk Setiap Tabel**

**Dimensions**
```powershell
# Buat subdirectories untuk setiap tabel dimensions
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_date
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_store
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_product
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_supplier
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_customer
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_cashier
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/dimensions/dim_payment
```

**Facts**
```powershell
# buat subdirectories untuk setiap tabel dimensions
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_sales
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_daily_sales
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_store_performance
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_product_performance
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_store_daily_balance
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_product_daily_movement
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_customer_daily_activity
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_promo_coverage
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_product_availability
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_daily_snapshot
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_store_snapshot
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_customer_accumulation
docker exec -it namenode hdfs dfs -mkdir -p /user/datalake/retail/facts/fact_store_accumulation
```

### **Langkah 5:Upload File Parquet ke HDFS**

**Upload Dimensions:**
```powershell
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_date.parquet /user/datalake/retail/dimensions/dim_date/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_store.parquet /user/datalake/retail/dimensions/dim_store/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_product.parquet /user/datalake/retail/dimensions/dim_product/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_supplier.parquet /user/datalake/retail/dimensions/dim_supplier/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_customer.parquet /user/datalake/retail/dimensions/dim_customer/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_cashier.parquet /user/datalake/retail/dimensions/dim_cashier/
docker exec -it namenode hdfs dfs -put /data/dimensions/dim_payment.parquet /user/datalake/retail/dimensions/dim_payment/
```

**Upload Facts:**
```powershell
docker exec -it namenode hdfs dfs -put /data/facts/fact_sales.parquet /user/datalake/retail/facts/fact_sales/
docker exec -it namenode hdfs dfs -put /data/facts/fact_daily_sales.parquet /user/datalake/retail/facts/fact_daily_sales/
docker exec -it namenode hdfs dfs -put /data/facts/fact_store_performance.parquet /user/datalake/retail/facts/fact_store_performance/
docker exec -it namenode hdfs dfs -put /data/facts/fact_product_performance.parquet /user/datalake/retail/facts/fact_product_performance/
docker exec -it namenode hdfs dfs -put /data/facts/fact_store_daily_balance.parquet /user/datalake/retail/facts/fact_store_daily_balance/
docker exec -it namenode hdfs dfs -put /data/facts/fact_product_daily_movement.parquet /user/datalake/retail/facts/fact_product_daily_movement/
docker exec -it namenode hdfs dfs -put /data/facts/fact_customer_daily_activity.parquet /user/datalake/retail/facts/fact_customer_daily_activity/
docker exec -it namenode hdfs dfs -put /data/facts/fact_promo_coverage.parquet /user/datalake/retail/facts/fact_promo_coverage/
docker exec -it namenode hdfs dfs -put /data/facts/fact_product_availability.parquet /user/datalake/retail/facts/fact_product_availability/
docker exec -it namenode hdfs dfs -put /data/facts/fact_daily_snapshot.parquet /user/datalake/retail/facts/fact_daily_snapshot/
docker exec -it namenode hdfs dfs -put /data/facts/fact_store_snapshot.parquet /user/datalake/retail/facts/fact_store_snapshot/
docker exec -it namenode hdfs dfs -put /data/facts/fact_customer_accumulation.parquet /user/datalake/retail/facts/fact_customer_accumulation/
docker exec -it namenode hdfs dfs -put /data/facts/fact_store_accumulation.parquet /user/datalake/retail/facts/fact_store_accumulation/
```

### **Langkah 6: Verifikasi Upload**
```powershell
docker exec -it namenode hdfs dfs -ls -R /user/datalake/retail/
```
## 🗄️ Penggunaan

### **Langkah 7: Buat Tabel Hive**

Jalankan script untuk membuat semua tabel:
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -f /warehouse/create_tables.hql
```

### **Langkah 8: Verifikasi Tabel**
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

Di dalam Beeline:
```sql
-- Lihat semua databases
SHOW DATABASES;

-- Masuk ke database retail_dw
USE retail_dw;

-- Lihat semua tabel
SHOW TABLES;

-- Lihat struktur tabel
DESCRIBE dim_store;
DESCRIBE fact_sales;

-- Test query
SELECT * FROM dim_store;
SELECT * FROM fact_sales LIMIT 10;
```

### **Langkah 9: Jalankan Demo Queries**

Jalankan demo queries:
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -f /warehouse/demo_queries.hql
```
---

