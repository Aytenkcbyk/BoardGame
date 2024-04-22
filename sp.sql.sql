-- Senaryo Açıklaması:
-- Bu stored procedure, bir oyunun bilgilerini güncellemek için tasarlanmıştır.
-- Oyunun adı, açıklaması ve çıkış tarihi güncellenecektir.
-- Eğer güncelleme işlemi başarılıysa, bir oyun oturumu başlatılacak ve bu oturumun bilgileri kaydedilecektir.

-- Nesnenin var olup olmadığını kontrol et ve varsa sil
IF OBJECT_ID('sp_GuncelleOyunBilgileri', 'P') IS NOT NULL
    DROP PROCEDURE sp_GuncelleOyunBilgileri;
GO

-- Stored Procedure Oluşturma
CREATE PROCEDURE sp_GuncelleOyunBilgileri
    @OyunID INT,
    @YeniAd VARCHAR(40),
    @YeniAciklama VARCHAR(50),
    @YeniCikisTarihi DATE
AS
BEGIN
    -- TRANSACTION Başlat
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Oyun bilgilerini güncelle
        UPDATE tbl_boardgame
        SET Ad = @YeniAd,
            Aciklama = @YeniAciklama,
            Cikis_tarihi = @YeniCikisTarihi
        WHERE ID = @OyunID;

        -- Oyun oturumu başlat
        DECLARE @OturumID INT;

        INSERT INTO tbl_oyun_oturumu (Aciklama, Baslangic_tarihi, Lokasiyon_ID, Oyun_olusturan, Oynanan_oyun)
        VALUES ('Yeni oyun oturumu başlatıldı', GETDATE(), 1, 1, @OyunID);

        SET @OturumID = SCOPE_IDENTITY();

        -- TRANSACTION Bitir (Commit)
        COMMIT;

        -- Test etmek için oluşturulan oyun oturumu ID'sini döndür
        SELECT @OturumID AS OturumID;

    END TRY
    -- Hata durumunda TRANSACTION'ı geri al (Rollback)
    BEGIN CATCH
        ROLLBACK;

        -- Hata mesajını döndür
        SELECT ERROR_MESSAGE() AS HataMesaji;
    END CATCH;
END;
GO

-- Stored Procedure'ı test et

-- Bunun doğru bir şekilde çalışması lazım. Burada sonuç olarak eklenen Oturum ID'sini bekliyoruz 
EXEC sp_GuncelleOyunBilgileri 1, 'Hatali olmayan', 'Bu Aciklama, tabloda gozukmesi gerekiyor', '2023-12-01';
-- SP hata return edeceğini test etmek için, hatalı bir ID eklemeye çalışalım.
EXEC sp_GuncelleOyunBilgileri -1, 'Hatali', 'Bu Aciklama, tabloda gozukmemesi gerekiyor', '2023-01-01';
GO
-- Burada sadece Hatalı olmayan oyun bilgilerini görmemiz gerekiyor. Hatalı olan bilgilerini görmememizin sebebi, ROLLBACK yapmamızdır
SELECT * FROM tbl_boardgame
-- Burada yeni oluşturulan oyun oturumun tabloya eklendiğni test ediliyor
SELECT * FROM tbl_oyun_oturumu
