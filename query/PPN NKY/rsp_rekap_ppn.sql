USE [ISAPabrikPenjualan]
GO
/****** Object:  StoredProcedure [dbo].[rsp_rekap_ppn]    Script Date: 09/08/2022 08:12:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Sayyid>
-- Create date: <Create Date,2022-08-30,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[rsp_rekap_ppn]
	@fromDate date, @toDate date
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
    Calculated_Jenis, Calculated_Periode,
    SUM(Nominal)Nominal
FROM
(
select
		('G. PPN Masukan') Calculated_Jenis,
		(CONVERT(VARCHAR(6), np.TglNota, 112)) Calculated_Periode,
		Sum((npd.HargaNota / NULLIF(npd.QtyPO, 0))* PPN)/100 Nominal
		from ISAPabrik.dbo.NotaPembelianDetail npd
inner join ISAPabrik.dbo.NotaPembelian np (nolock) on np.RowID= npd.IDNotaPembelian
inner join ISAPabrik.dbo.SJNotaPembelianDetail sjd (nolock) on sjd.IDNotaPembelian = npd.IDNotaPembelian
where np.TglNota BETWEEN @fromDate AND @toDate
group by PPN,np.TglNota

union all
select 
      ('F. PPN Keluar') Calculated_Jenis,
		(CONVERT(VARCHAR(6), npj.TglNota, 112))  [Calculated_Periode],
		Sum((npjd.Harga / NULLIF(npjd.Qty, 0))* npjd.PPN)/100 Nominal
		 from ISAPabrikPenjualan.dbo.NotaPenjualanDetail npjd 
inner join ISAPabrikPenjualan.dbo.NotaPenjualan npj (nolock) on npj.RowID =npjd.IDNotaPenjualan
where npj.TglNota BETWEEN @fromDate AND @toDate
group by npjd.PPN,npj.TglNota

union all
select 
(CASE WHEN  c.KdCustomer = '011' THEN 'a. Omset SAP' WHEN  c.KdCustomer NOT IN ('011','CAB29') THEN 'c. Omset OEM'END)  Calculated_Jenis,
(CONVERT(VARCHAR(6), npj.TglNota, 112))  Calculated_Periode,
Sum(npjd.Harga) Nominal


from
ISAPabrikPenjualan.dbo.NotaPenjualanDetail npjd 
inner join ISAPabrikPenjualan.dbo.NotaPenjualan npj (nolock) on npj.RowID = npjd.IDNotaPenjualan
inner join ISAPabrikPenjualan.dbo.Customer c (nolock) on c.RowID = npj.IDCustomer
where npj.TglNota BETWEEN @fromDate AND @toDate
group by npj.TglNota,c.KdCustomer

)t
group by
    Calculated_Jenis, Calculated_Periode
END
