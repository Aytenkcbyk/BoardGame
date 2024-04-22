-- Senaryo Açıklaması:
-- Bu VIEW, bir kullanıcının tüm oyun oturumlarındaki detaylı bilgilerini getirir ve her oturumdaki ortalama puanını hesaplar.

-- Nesnenin var olup olmadığını kontrol et ve varsa sil
IF OBJECT_ID('dbo.vw_UserGameSessionDetails', 'V') IS NOT NULL
    DROP VIEW dbo.vw_UserGameSessionDetails;
GO

-- VIEW oluşturma
CREATE VIEW dbo.vw_UserGameSessionDetails
AS
SELECT
    o.ID AS OturumID,
    o.Aciklama AS OturumAciklama,
    FORMAT(o.Baslangic_tarihi, 'dd.MM.yyyy HH:mm:ss') AS BaslangicTarihi,
    CASE
        WHEN o.Bitirilis_tarihi IS NULL THEN 'Oturum Devam Ediyor'
        ELSE FORMAT(o.Bitirilis_tarihi, 'dd.MM.yyyy HH:mm:ss')
    END AS BitirilisTarihi,
    u.Ad + ' ' + u.Soyad AS UyeAdSoyad,
    b.Ad AS OyunAdi,
    g.Puan AS OturumPuan,
    dbo.fn_GetUserAveragePoints(u.ID) AS UyeOrtalamaPuan
FROM
    tbl_oyun_oturumu o
JOIN
    tbl_oturum_oynayanlar g ON o.ID = g.Oturum_ID
JOIN
    tbl_uye u ON g.Uye_ID = u.ID
JOIN
    tbl_boardgame b ON o.Oynanan_oyun = b.ID;
GO

-- VIEW'ı test et
/*
INSERT INTO tbl_oturum_oynayanlar (Oturum_ID, Uye_ID, Puan, Sira)
VALUES
    (1, 1, 80, 1),
    (1, 2, 90, 2),
    (2, 2, 85, 1),
    (2, 3, 95, 2),
    (3, 3, 88, 1),
    (3, 4, 92, 2);
*/

SELECT
    v.OturumID,
    v.OturumAciklama,
    v.BaslangicTarihi,
    v.BitirilisTarihi,
    v.UyeAdSoyad,
    v.OyunAdi,
    v.OturumPuan,
    v.UyeOrtalamaPuan
FROM
    dbo.vw_UserGameSessionDetails v
WHERE
    v.UyeOrtalamaPuan > 85;
