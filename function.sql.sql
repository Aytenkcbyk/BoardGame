-- Senaryo Açıklaması:
-- Bu fonksiyon, bir kullanıcının tüm oyun otrumlarında aldığı toplam puanın ortalamasını hesaplıyor.
-- Nesnenin var olup olmadığını kontrol et ve varsa sil
IF OBJECT_ID('dbo.fn_GetUserAveragePoints', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetUserAveragePoints;
GO

-- Function oluşturma
CREATE FUNCTION dbo.fn_GetUserAveragePoints
(
    @UyeID INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @OrtalamaPuan FLOAT;

    -- Belirtilen üye için tüm oyun oturumlarındaki puanların ortalamasını hesapla.
    SELECT @OrtalamaPuan = AVG(Puan)
    FROM tbl_oturum_oynayanlar
    WHERE Uye_ID = @UyeID;

    -- Eğer hiç puan yoksa 0 döndür.
    IF @OrtalamaPuan IS NULL
        SET @OrtalamaPuan = 0;

    RETURN @OrtalamaPuan;
END;
GO

-- Fonsiyonu test et
-- Örnek olarak, üye ID'si 1 için ortalama puanı getir.
DECLARE @TestOrtalamaPuan FLOAT;

-- Fonksiyonu çağır ve sonucu al.
SET @TestOrtalamaPuan = dbo.fn_GetUserAveragePoints(1);

-- Sonucu göster.
PRINT 'Uye ID 1 icin ortalama puan: ' + CAST(@TestOrtalamaPuan AS VARCHAR);
