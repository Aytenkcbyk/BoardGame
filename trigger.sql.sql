-- Senaryo Aciklamasi:
-- Bu trigger, tbl_boardgame tablosuna ekleme veya guncelleme yapildiginda calisir.
-- Eklenen veya guncellenen oyun bilgileri kontrol edilir, zorluk seviyesi 5'ten yuksek durumunda islem iptal edilir.
-- Eger islem basariliysa, bir oyun oturumu baslatilir ve bu oturumun bilgileri kaydedilir.

-- Bu tablo, tr_BoardgameTrigger tetikleyicisi tarafindan guncellenen oyunlarin bilgilerini saklamak icin kullanilacaktir.
CREATE TABLE tbl_guncellenen_oyunlar (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    OyunID INT NOT NULL,
    Ad VARCHAR(40) NOT NULL,
    Zorluk FLOAT NOT NULL
);

IF OBJECT_ID('tr_BoardgameTrigger', 'TR') IS NOT NULL
    DROP TRIGGER tr_BoardgameTrigger;
GO

-- Trigger Olusturma
CREATE TRIGGER tr_BoardgameTrigger
ON tbl_boardgame
AFTER INSERT, UPDATE
AS
BEGIN
    -- TRANSACTION Baslat
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OyunID INT;
        DECLARE @Ad VARCHAR(40);
        DECLARE @Zorluk FLOAT;

        -- INSERTED tablosundan eklenen/guncellenen verileri al
        SELECT @OyunID = ID, @Ad = Ad, @Zorluk = Zorluk
        FROM INSERTED;

        -- Kontrol sartlari burada belirlenir
        IF @Zorluk > 5.0
        BEGIN
            -- Zorluk seviyesi 5'ten yuksek olan oyunlarin guncellenmesi iptal edilir (ROLLBACK)
            RAISERROR('Oyunun zorluk seviyesi 5ten yuksek olamaz.', 16, 1) WITH NOWAIT;
            ROLLBACK;
			-- WAITFOR DELAY ile mesajın daha uzun süre görüntülenmesini sağlayabilirsiniz
            WAITFOR DELAY '00:10:00'; -- Bu örnekte 5 saniye beklenir
        END
        ELSE
        BEGIN
            -- Stored Procedure'ı çağır
            EXEC sp_GuncelleOyunBilgileri @OyunID, @Ad, 'Yeni Aciklama', '2023-12-29';
        END

        -- Ikinci kisimda, eldeki verilerden belirlediginiz bir kismi baska bir tabloya ekleyebilir veya guncelleme yapabilirsiniz.
        -- Bu ornekte, guncellenen oyunun bilgilerini baska bir tabloya ekleyelim (ornegin, tbl_guncellenen_oyunlar).
        INSERT INTO tbl_guncellenen_oyunlar (OyunID, Ad, Zorluk)
        VALUES (@OyunID, @Ad, @Zorluk);

        -- TRANSACTION Bitir (Commit)
        COMMIT;

    END TRY
    -- Hata durumunda TRANSACTION'i geri al (Rollback)
    BEGIN CATCH
        ROLLBACK;

        -- Hata mesajini dondur
        SELECT ERROR_MESSAGE() AS HataMesaji;
    END CATCH;
END;
GO
-- Trigger'i test et

-- Test senaryosu: Gecerli bir zorluk seviyesine sahip bir oyun ekleyelim
INSERT INTO tbl_boardgame (Ad, Zorluk, Cikis_tarihi, En, Boy, Yukseklik) VALUES ('Zor Oyun', 4.5, '2023-12-01', 10, 100, 100);

-- Burada islem basarili olmali ve yeni bir oyun oturumu olusturulmus olmali
-- Olusturulan oyun oturumu ID'sini gormek icin asagidaki sorguyu kullanabilirsiniz
-- SELECT * FROM tbl_oyun_oturumu

-- Test senaryosu: Zorluk seviyesi 5'ten yuksek olan bir oyun ekleyelim
INSERT INTO tbl_boardgame (Ad, Zorluk, Cikis_tarihi, En, Boy, Yukseklik) VALUES ('Cok Zor Oyun', 5.5, '2023-12-01',  10, 100, 100);

-- Burada islem basarisiz olmali ve hata mesaji gosterilmeli
