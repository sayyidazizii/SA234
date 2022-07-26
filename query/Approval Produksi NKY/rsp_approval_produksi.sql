USE [ISAPabrikProduksi]
GO
/****** Object:  StoredProcedure [dbo].[rsp_approval_produksi]    Script Date: 09/08/2022 08:03:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Sayyid>
-- Create date: < Date,2022-08-30,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[rsp_approval_produksi] 
	-- Add the parameters for the stored procedure here
	 @fromdate date, @todate date, 
	 @IDLini uniqueidentifier=null
	,@ProsesID uniqueidentifier=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select 
        hpwo.NoProses,
		CONVERT (date,hpwo.TglProses) TglProses,
		P.Nama,
		hpwo.IDLiniProduksi,
		LP.NmLine,
		hpwo.ProsesID,  
		hpwo.ProsesKe,
		m.NmMesin,
		hpwo.Shift,
		hpwo.IDMesin,
		hpwo.fKirim,
		hpwo.JamAwal
		,hpwo.JamAkhir,
		hpwo.CreatedBy,
		hpwo.Approved,
		hpwo.Approvedby,
		hpwo.ApprovedDate
		
 FROM ISAPabrikProduksi.dbo.HasilProsesWO hpwo (nolock)   
 INNER JOIN ISAPabrik.DBO.LineProduksi LP (nolock) ON LP.RowID=IDLiniProduksi    
 LEFT JOIN ISAPabrik.DBO.Mesin m (nolock) ON m.RowID=IDMesin    
 LEFT JOIN ProsesProduksi P (nolock) ON P.RowID=hpwo.ProsesID  
where hpwo.IDLiniProduksi = @IDLini AND hpwo.TglProses between @fromdate AND @todate
group by hpwo.NoProses,hpwo.TglProses,P.Nama,IDLiniProduksi,LP.NmLine,hpwo.ProsesID,hpwo.ProsesKe,m.NmMesin,hpwo.Shift,hpwo.IDMesin,hpwo.fKirim,hpwo.JamAwal,hpwo.JamAkhir,hpwo.CreatedBy,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate 


END
