USE [ISAPabrikProduksi]
GO
/****** Object:  StoredProcedure [dbo].[rsp_harianNakayama_v1]    Script Date: 09/08/2022 08:04:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Agus S
-- Create date: 19 Juli 2018
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[rsp_harianNakayama_v1]
 @startdate date ,--='20180301',     
 @enddate date ,--='20180331',
 @LineProduksiRowID uniqueidentifier ,--='6576C124-9EBC-4A49-902F-A0660499DFB9',
 @fgRekap int = 0, -- 0 Rinci, 1 Rekap
 @Satuan int = 2 -- 1 = tonase, 2 = pcs 
AS
BEGIN
declare @fromdate2 date = @startdate

declare @Temp table (
	IDMesin uniqueidentifier,
	IDMaterial uniqueidentifier,
	IDProses uniqueidentifier,
    NmMesin varchar(500),
    NmProses varchar(500),
    KdMaterial varchar(500),
    NmMaterial varchar(500),
    Approved varchar(max),
    Approvedby varchar(max),
    ApprovedDate varchar(max),
    tgl int,
    shift int,
    QtyPlan float,
    QtyOk float,
    QtySp float
)

declare @rawtable table (
	IDParam uniqueidentifier,
	IDMaterial uniqueidentifier,
    NmParam varchar(500),
    KdMaterial varchar(500),
    NmMaterial varchar(500),
    Approved varchar(max),
    Approvedby varchar(max),
    ApprovedDate varchar(max),
    tgl int,
    shift int,
    QtyPlan float,
    QtyOk float,
    QtySp float
)

declare @Plantable table (
	IDParam uniqueidentifier,
	IDMaterial uniqueidentifier,
    NmParam varchar(500),
    KdMaterial varchar(500),
    NmMaterial varchar(500),
    Approved varchar(max),
    Approvedby varchar(max),
    ApprovedDate varchar(max),
    tgl int,
    shift int,
    QtyPlan float
)

insert @Temp 
select 
	pm.MesinRowID, 
	hpwod.IDMaterial, 
	hpwo.ProsesID, 
	m.NmMesin, 
	pp.Nama,
	mt.KdMaterial, 
	mt.NmMaterial, 
	hpwo.Approved,
	hpwo.Approvedby,
	hpwo.ApprovedDate,
	datepart(day, hpwo.tglproses) tgl, 
	hpwo.Shift,
	SUM(hpwod.QtyTarget) QtyPlan, 
	SUM(hpwod.Qty) QtyOK, 
	SUM(hpwod.SPOk) QtySP
from hasilproseswo hpwo 
left join ISAPabrik.dbo.ProsesMesin pm on hpwo.RowID=pm.RefRowID
left join ISAPabrik.dbo.Mesin  m on m.RowID=pm.MesinRowID
join HasilProsesWODetail hpwod on hpwod.IDHPWO = hpwo.RowID
left join ISAPabrik.dbo.Material mt on mt.RowID = hpwod.IDMaterial
join ProsesProduksi pp on pp.RowID = hpwo.ProsesID
where hpwo.idliniproduksi = @LineProduksiRowID
and hpwo.tglproses between @startdate and  @enddate
and hpwo.Approved = '1'
group by pm.MesinRowID, hpwod.IDMaterial, hpwo.ProsesID, m.NmMesin, pp.Nama, mt.KdMaterial, mt.NmMaterial,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwo.tglproses, hpwo.Shift,hpwod.QtyTarget

CREATE TABLE #Temp
(
	IDParam uniqueidentifier,
	IDMaterial uniqueidentifier,
	NmParam varchar(500),
	KdMaterial varchar(500),
	NmMaterial varchar(500),
	Approved varchar(max),
    Approvedby varchar(max),
    ApprovedDate varchar(max),
	Shift int
)

if (@LineProduksiRowID ='34D40739-5C35-43B1-BFE5-4C481A1BF09D')
begin
	insert into @rawtable
		select t.IDProses, t.IDMaterial, t.NmProses, t.KdMaterial, t.NmMaterial,t.Approved,t.Approvedby,t.ApprovedDate, t.tgl, t.shift,SUM(t.QtyPlan), SUM(t.QtyOk), SUM(t.QtySp)
	from @Temp t
	group by t.IDProses, t.IDMaterial, t.NmProses, t.KdMaterial, t.NmMaterial,t.Approved,t.Approvedby,t.ApprovedDate, t.tgl, t.shift
	
	insert @Plantable
		 select 
			hpwo.IDMesin,
			hpwod.IDMaterial,
			m.NmMesin,
			mt.KdMaterial,
			mt.NmMaterial,
			hpwo.Approved,
			hpwo.Approvedby,
			hpwo.ApprovedDate,
			datepart(day,hpwo.TglProses) tgl,
			hpwo.Shift,
			SUM(ISNull(hpwod.QtyTarget,0))QtyPlan
			from
			ISAPabrikProduksi.dbo.HasilProsesWODetail hpwod
			join ISAPabrik.dbo.Material mt on mt.RowID = hpwod.IDMaterial
			join HasilProsesWO hpwo on hpwo.RowID = hpwod.IDHPWO
			left join ISAPabrik.dbo.Mesin m on m.RowID = hpwo.IDMesin
			where hpwo.TglProses between  @startdate and @enddate
			and hpwo.Approved = '1'
	group by  hpwo.IDMesin, hpwod.IDMaterial, m.NmMesin, mt.KdMaterial, mt.NmMaterial,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwo.TglProses, hpwo.Shift
end
else
begin
	insert into @rawtable
	select t.IDMesin, t.IDMaterial, t.NmMesin, t.KdMaterial, t.NmMaterial,t.Approved,t.Approvedby,t.ApprovedDate, t.tgl, t.shift,SUM(t.QtyPlan), SUM(t.QtyOk), SUM(t.QtySp)
	from @Temp t
	group by t.IDMesin, t.IDMaterial, t.NmMesin, t.KdMaterial, t.NmMaterial,t.Approved,t.Approvedby,t.ApprovedDate, t.tgl, t.shift
	
	
	--edit SA
	insert @Plantable
		 select 
			hpwo.IDMesin,
			hpwod.IDMaterial,
			m.NmMesin,
			mt.KdMaterial,
			mt.NmMaterial,
			hpwo.Approved,
			hpwo.Approvedby,
			hpwo.ApprovedDate,
			datepart(day,hpwo.TglProses) tgl,
			hpwo.Shift,
			SUM(ISNull(hpwod.QtyTarget,0))QtyPlan
			from
			ISAPabrikProduksi.dbo.HasilProsesWODetail hpwod
			join ISAPabrik.dbo.Material mt on mt.RowID = hpwod.IDMaterial
			join HasilProsesWO hpwo on hpwo.RowID = hpwod.IDHPWO
			left join ISAPabrik.dbo.Mesin m on m.RowID = hpwo.IDMesin
			where hpwo.TglProses between  @startdate and @enddate
			and hpwo.Approved = '1'
	group by  hpwo.IDMesin, hpwod.IDMaterial, m.NmMesin, mt.KdMaterial, mt.NmMaterial,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwo.TglProses, hpwo.Shift
end

	insert into #Temp
	select 
		distinct IDParam, IDMaterial, NmParam, KdMaterial, NmMaterial,Approved,Approvedby,ApprovedDate,sh.Shift  
	from @rawtable
	outer apply
	(
		select 1 as Shift
		union
		select 2 as Shift
		union
		select 3 as Shift
	)sh
	
	-- Untuk menambah kolom DAy
	declare @Loop int = 1, @endloop int = 31
	while @Loop <= @endloop
	begin
		
		declare @d int = 0
		select @d = @Loop
		declare @query nvarchar(MAX)= '
		ALTER table #Temp
		ADD [QtyOk'+convert(varchar(3),RIGHT('0'+convert(varchar(2),@d), 2))+'] int'
		
		declare @query2 nvarchar(MAX)= '
		ALTER table #Temp
		ADD [QtySp'+convert(varchar(3),RIGHT('0'+convert(varchar(2),@d), 2))+'] int'
		
		declare @query3 nvarchar(MAX)= '
		ALTER table #Temp
		ADD [QtyPlan'+convert(varchar(3),RIGHT('0'+convert(varchar(2),@d), 2))+'] int'
		
		exec sp_executesql @query3
		exec sp_executesql @query
		exec sp_executesql @query2
		
		set @Loop = @Loop + 1;
	end
	
	declare @NmParam varchar(MAX)
	declare @KdMaterial varchar(MAX)
	declare @Day varchar(10)
	declare @Shift int
	declare @Qty float
	
	-- Perulangan untuk Update Data kolomnya
	DECLARE Detail CURSOR LOCAL FOR	
	select 
		NmParam, KdMaterial, 'QtyOk' + RIGHT('0' + convert(varchar(2),tgl),2) day, shift, QtyOk 
	from @rawtable

	OPEN Detail

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN

		declare @qu nvarchar(MAX) = N'
		update #Temp set ['+convert(varchar(10), @Day)+'] = '+convert(varchar(10), @Qty)+'
		where NmParam = '''+convert(varchar(100), @NmParam)+''' and KdMaterial = '''+convert(varchar(100), @KdMaterial)+''' 
		and Shift = '''+convert(varchar(100), @Shift)+''''
		
		exec sp_executesql @qu

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty
	END

	CLOSE Detail
	DEALLOCATE Detail
	
	DECLARE Detail CURSOR LOCAL FOR	
	select 
		NmParam, KdMaterial, 'QtySp' + RIGHT('0' + convert(varchar(2),tgl),2) day, shift, QtySP 
	from @rawtable
	where QtySP>0 

	OPEN Detail

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN

		declare @qu2 nvarchar(MAX) = N'
		update #Temp set ['+convert(varchar(10), @Day)+'] = '+convert(varchar(10), @Qty)+'
		where NmParam = '''+convert(varchar(100), @NmParam)+''' and KdMaterial = '''+convert(varchar(100), @KdMaterial)+''' 
		and Shift = '''+convert(varchar(100), @Shift)+''''
		
		exec sp_executesql @qu2

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty
	END

	CLOSE Detail
	DEALLOCATE Detail
	
	DECLARE Detail CURSOR LOCAL FOR	
	select 
		NmParam, KdMaterial, 'QtyPlan' + RIGHT('0' + convert(varchar(2),tgl),2) day, shift, QtyPlan 
    from @rawtable
	--from @Plantable
    where QtySP>0 

	OPEN Detail

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty

	WHILE @@FETCH_STATUS = 0
	BEGIN

		select @qu2 = N'
		update #Temp set ['+convert(varchar(10), @Day)+'] = '+convert(varchar(10), @Qty)+'
		where NmParam = '''+convert(varchar(100), @NmParam)+''' and KdMaterial = '''+convert(varchar(100), @KdMaterial)+''' 
		and Shift = '''+convert(varchar(100), @Shift)+''''
		
		exec sp_executesql @qu2

	FETCH NEXT FROM Detail
	INTO @NmParam, @KdMaterial, @Day, @Shift, @Qty
	END

	CLOSE Detail
	DEALLOCATE Detail

if (@fgRekap = 0)
begin
	if (@Satuan = 2)
	begin
		select 
			t.*,
			case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end BeratCetak 	
		from #Temp t
		outer apply 
		(
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.IDMaterial
			and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')				
		) qwip
	end
	else
	begin
		select 
			t.IDMaterial, t.IDParam, t.NmParam, t.KdMaterial, t.NmMaterial, t.Shift,
			t.QtyPlan01 * Qty_WIP QtyPlan01, t.QtyPlan02 * Qty_WIP QtyPlan02, t.QtyPlan03 * Qty_WIP QtyPlan03, t.QtyPlan04 * Qty_WIP QtyPlan04, t.QtyPlan05 * Qty_WIP QtyPlan05, t.QtyPlan06 * Qty_WIP QtyPlan06, t.QtyPlan07 * Qty_WIP QtyPlan07, t.QtyPlan08 * Qty_WIP QtyPlan08, t.QtyPlan09 * Qty_WIP QtyPlan09, t.QtyPlan10 * Qty_WIP QtyPlan10,
			t.QtyPlan11 * Qty_WIP QtyPlan11, t.QtyPlan12 * Qty_WIP QtyPlan12, t.QtyPlan13 * Qty_WIP QtyPlan13, t.QtyPlan14 * Qty_WIP QtyPlan14, t.QtyPlan15 * Qty_WIP QtyPlan15, t.QtyPlan16 * Qty_WIP QtyPlan16, t.QtyPlan17 * Qty_WIP QtyPlan17, t.QtyPlan18 * Qty_WIP QtyPlan18, t.QtyPlan19 * Qty_WIP QtyPlan19, t.QtyPlan20 * Qty_WIP QtyPlan20,
			t.QtyPlan21 * Qty_WIP QtyPlan21, t.QtyPlan22 * Qty_WIP QtyPlan22, t.QtyPlan23 * Qty_WIP QtyPlan23, t.QtyPlan24 * Qty_WIP QtyPlan24, t.QtyPlan25 * Qty_WIP QtyPlan25, t.QtyPlan26 * Qty_WIP QtyPlan26, t.QtyPlan27 * Qty_WIP QtyPlan27, t.QtyPlan28 * Qty_WIP QtyPlan28, t.QtyPlan29 * Qty_WIP QtyPlan29, t.QtyPlan30 * Qty_WIP QtyPlan30,
			t.QtyPlan31 * Qty_WIP QtyPlan31,
			t.QtyOk01 * Qty_WIP QtyOk01, t.QtyOk02 * Qty_WIP QtyOk02, t.QtyOk03 * Qty_WIP QtyOk03, t.QtyOk04 * Qty_WIP QtyOk04, t.QtyOk05 * Qty_WIP QtyOk05, t.QtyOk06 * Qty_WIP QtyOk06, t.QtyOk07 * Qty_WIP QtyOk07, t.QtyOk08 * Qty_WIP QtyOk08, t.QtyOk09 * Qty_WIP QtyOk09, t.QtyOk10 * Qty_WIP QtyOk10,
			t.QtyOk11 * Qty_WIP QtyOk11, t.QtyOk12 * Qty_WIP QtyOk12, t.QtyOk13 * Qty_WIP QtyOk13, t.QtyOk14 * Qty_WIP QtyOk14, t.QtyOk15 * Qty_WIP QtyOk15, t.QtyOk16 * Qty_WIP QtyOk16, t.QtyOk17 * Qty_WIP QtyOk17, t.QtyOk18 * Qty_WIP QtyOk18, t.QtyOk19 * Qty_WIP QtyOk19, t.QtyOk20 * Qty_WIP QtyOk20,
			t.QtyOk21 * Qty_WIP QtyOk21, t.QtyOk22 * Qty_WIP QtyOk22, t.QtyOk23 * Qty_WIP QtyOk23, t.QtyOk24 * Qty_WIP QtyOk24, t.QtyOk25 * Qty_WIP QtyOk25, t.QtyOk26 * Qty_WIP QtyOk26, t.QtyOk27 * Qty_WIP QtyOk27, t.QtyOk28 * Qty_WIP QtyOk28, t.QtyOk29 * Qty_WIP QtyOk29, t.QtyOk30 * Qty_WIP QtyOk30,
			t.QtyOk31 * Qty_WIP QtyOk31,
			t.QtySp01 * Qty_WIP QtySp01, t.QtySp02 * Qty_WIP QtySp02, t.QtySp03 * Qty_WIP QtySp03, t.QtySp04 * Qty_WIP QtySp04, t.QtySp05 * Qty_WIP QtySp05, t.QtySp06 * Qty_WIP QtySp06, t.QtySp07 * Qty_WIP QtySp07, t.QtySp08 * Qty_WIP QtySp08, t.QtySp09 * Qty_WIP QtySp09, t.QtySp10 * Qty_WIP QtySp10,
			t.QtySp11 * Qty_WIP QtySp11, t.QtySp12 * Qty_WIP QtySp12, t.QtySp13 * Qty_WIP QtySp13, t.QtySp14 * Qty_WIP QtySp14, t.QtySp15 * Qty_WIP QtySp15, t.QtySp16 * Qty_WIP QtySp16, t.QtySp17 * Qty_WIP QtySp17, t.QtySp18 * Qty_WIP QtySp18, t.QtySp19 * Qty_WIP QtySp19, t.QtySp20 * Qty_WIP QtySp20,
			t.QtySp21 * Qty_WIP QtySp21, t.QtySp22 * Qty_WIP QtySp22, t.QtySp23 * Qty_WIP QtySp23, t.QtySp24 * Qty_WIP QtySp24, t.QtySp25 * Qty_WIP QtySp25, t.QtySp26 * Qty_WIP QtySp26, t.QtySp27 * Qty_WIP QtySp27, t.QtySp28 * Qty_WIP QtySp28, t.QtySp29 * Qty_WIP QtySp29, t.QtySp30 * Qty_WIP QtySp30,
			t.QtySp31 * Qty_WIP QtySp31,
			case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end BeratCetak 
		from #Temp t
		outer apply 
		(
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.IDMaterial
			and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')				
		) qwip
	end
end
else
begin
	if (@Satuan = 2)
	begin
		select 
			t.IDMaterial, t.IDParam, t.NmParam, t.KdMaterial, t.NmMaterial,
			SUM(t.QtyPlan01) QtyPlan01, SUM(t.QtyPlan02) QtyPlan02, SUM(t.QtyPlan03) QtyPlan03, SUM(t.QtyPlan04) QtyPlan04, SUM(t.QtyPlan05) QtyPlan05, SUM(t.QtyPlan06) QtyPlan06, SUM(t.QtyPlan07) QtyPlan07, SUM(t.QtyPlan08) QtyPlan08, SUM(t.QtyPlan09) QtyPlan09, SUM(t.QtyPlan10) QtyPlan10,
			SUM(t.QtyPlan11) QtyPlan11, SUM(t.QtyPlan12) QtyPlan12, SUM(t.QtyPlan13) QtyPlan13, SUM(t.QtyPlan14) QtyPlan14, SUM(t.QtyPlan15) QtyPlan15, SUM(t.QtyPlan16) QtyPlan16, SUM(t.QtyPlan17) QtyPlan17, SUM(t.QtyPlan18) QtyPlan18, SUM(t.QtyPlan19) QtyPlan19, SUM(t.QtyPlan20) QtyPlan20,
			SUM(t.QtyPlan21) QtyPlan21, SUM(t.QtyPlan22) QtyPlan22, SUM(t.QtyPlan23) QtyPlan23, SUM(t.QtyPlan24) QtyPlan24, SUM(t.QtyPlan25) QtyPlan25, SUM(t.QtyPlan26) QtyPlan26, SUM(t.QtyPlan27) QtyPlan27, SUM(t.QtyPlan28) QtyPlan28, SUM(t.QtyPlan29) QtyPlan29, SUM(t.QtyPlan30) QtyPlan30,
			SUM(t.QtyPlan31) QtyPlan31,
			SUM(t.QtyOk01) QtyOk01, SUM(t.QtyOk02) QtyOk02, SUM(t.QtyOk03) QtyOk03, SUM(t.QtyOk04) QtyOk04, SUM(t.QtyOk05) QtyOk05, SUM(t.QtyOk06) QtyOk06, SUM(t.QtyOk07) QtyOk07, SUM(t.QtyOk08) QtyOk08, SUM(t.QtyOk09) QtyOk09, SUM(t.QtyOk10) QtyOk10,
			SUM(t.QtyOk11) QtyOk11, SUM(t.QtyOk12) QtyOk12, SUM(t.QtyOk13) QtyOk13, SUM(t.QtyOk14) QtyOk14, SUM(t.QtyOk15) QtyOk15, SUM(t.QtyOk16) QtyOk16, SUM(t.QtyOk17) QtyOk17, SUM(t.QtyOk18) QtyOk18, SUM(t.QtyOk19) QtyOk19, SUM(t.QtyOk20) QtyOk20,
			SUM(t.QtyOk21) QtyOk21, SUM(t.QtyOk22) QtyOk22, SUM(t.QtyOk23) QtyOk23, SUM(t.QtyOk24) QtyOk24, SUM(t.QtyOk25) QtyOk25, SUM(t.QtyOk26) QtyOk26, SUM(t.QtyOk27) QtyOk27, SUM(t.QtyOk28) QtyOk28, SUM(t.QtyOk29) QtyOk29, SUM(t.QtyOk30) QtyOk30,
			SUM(t.QtyOk31) QtyOk31,
			SUM(t.QtySp01) QtySp01, SUM(t.QtySp02) QtySp02, SUM(t.QtySp03) QtySp03, SUM(t.QtySp04) QtySp04, SUM(t.QtySp05) QtySp05, SUM(t.QtySp06) QtySp06, SUM(t.QtySp07) QtySp07, SUM(t.QtySp08) QtySp08, SUM(t.QtySp09) QtySp09, SUM(t.QtySp10) QtySp10,
			SUM(t.QtySp11) QtySp11, SUM(t.QtySp12) QtySp12, SUM(t.QtySp13) QtySp13, SUM(t.QtySp14) QtySp14, SUM(t.QtySp15) QtySp15, SUM(t.QtySp16) QtySp16, SUM(t.QtySp17) QtySp17, SUM(t.QtySp18) QtySp18, SUM(t.QtySp19) QtySp19, SUM(t.QtySp20) QtySp20,
			SUM(t.QtySp21) QtySp21, SUM(t.QtySp22) QtySp22, SUM(t.QtySp23) QtySp23, SUM(t.QtySp24) QtySp24, SUM(t.QtySp25) QtySp25, SUM(t.QtySp26) QtySp26, SUM(t.QtySp27) QtySp27, SUM(t.QtySp28) QtySp28, SUM(t.QtySp29) QtySp29, SUM(t.QtySp30) QtySp30,
			SUM(t.QtySp31) QtySp31,
			SUM(case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end) BeratCetak 
		from #Temp t
		outer apply 
		(
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.IDMaterial
			and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')				
		) qwip
		group by t.IDMaterial, t.IDParam, t.NmParam, t.KdMaterial, t.NmMaterial, qwip.Qty_WIP
	end
	else
	begin
		select 
			t.IDMaterial, t.IDParam, t.NmParam, t.KdMaterial, t.NmMaterial,
			SUM(t.QtyPlan01 * Qty_WIP) QtyPlan01, SUM(t.QtyPlan02 * Qty_WIP) QtyPlan02, SUM(t.QtyPlan03 * Qty_WIP) QtyPlan03, SUM(t.QtyPlan04 * Qty_WIP) QtyPlan04, SUM(t.QtyPlan05 * Qty_WIP) QtyPlan05, SUM(t.QtyPlan06 * Qty_WIP) QtyPlan06, SUM(t.QtyPlan07 * Qty_WIP) QtyPlan07, SUM(t.QtyPlan08 * Qty_WIP) QtyPlan08, SUM(t.QtyPlan09 * Qty_WIP) QtyPlan09, SUM(t.QtyPlan10 * Qty_WIP) QtyPlan10,
			SUM(t.QtyPlan11 * Qty_WIP) QtyPlan11, SUM(t.QtyPlan12 * Qty_WIP) QtyPlan12, SUM(t.QtyPlan13 * Qty_WIP) QtyPlan13, SUM(t.QtyPlan14 * Qty_WIP) QtyPlan14, SUM(t.QtyPlan15 * Qty_WIP) QtyPlan15, SUM(t.QtyPlan16 * Qty_WIP) QtyPlan16, SUM(t.QtyPlan17 * Qty_WIP) QtyPlan17, SUM(t.QtyPlan18 * Qty_WIP) QtyPlan18, SUM(t.QtyPlan19 * Qty_WIP) QtyPlan19, SUM(t.QtyPlan20 * Qty_WIP) QtyPlan20,
			SUM(t.QtyPlan21 * Qty_WIP) QtyPlan21, SUM(t.QtyPlan22 * Qty_WIP) QtyPlan22, SUM(t.QtyPlan23 * Qty_WIP) QtyPlan23, SUM(t.QtyPlan24 * Qty_WIP) QtyPlan24, SUM(t.QtyPlan25 * Qty_WIP) QtyPlan25, SUM(t.QtyPlan26 * Qty_WIP) QtyPlan26, SUM(t.QtyPlan27 * Qty_WIP) QtyPlan27, SUM(t.QtyPlan28 * Qty_WIP) QtyPlan28, SUM(t.QtyPlan29 * Qty_WIP) QtyPlan29, SUM(t.QtyPlan30 * Qty_WIP) QtyPlan30,
			SUM(t.QtyPlan31 * Qty_WIP) QtyPlan31,
			SUM(t.QtyOk01 * Qty_WIP) QtyOk01, SUM(t.QtyOk02 * Qty_WIP) QtyOk02, SUM(t.QtyOk03 * Qty_WIP) QtyOk03, SUM(t.QtyOk04 * Qty_WIP) QtyOk04, SUM(t.QtyOk05 * Qty_WIP) QtyOk05, SUM(t.QtyOk06 * Qty_WIP) QtyOk06, SUM(t.QtyOk07 * Qty_WIP) QtyOk07, SUM(t.QtyOk08 * Qty_WIP) QtyOk08, SUM(t.QtyOk09 * Qty_WIP) QtyOk09, SUM(t.QtyOk10 * Qty_WIP) QtyOk10,
			SUM(t.QtyOk11 * Qty_WIP) QtyOk11, SUM(t.QtyOk12 * Qty_WIP) QtyOk12, SUM(t.QtyOk13 * Qty_WIP) QtyOk13, SUM(t.QtyOk14 * Qty_WIP) QtyOk14, SUM(t.QtyOk15 * Qty_WIP) QtyOk15, SUM(t.QtyOk16 * Qty_WIP) QtyOk16, SUM(t.QtyOk17 * Qty_WIP) QtyOk17, SUM(t.QtyOk18 * Qty_WIP) QtyOk18, SUM(t.QtyOk19 * Qty_WIP) QtyOk19, SUM(t.QtyOk20 * Qty_WIP) QtyOk20,
			SUM(t.QtyOk21 * Qty_WIP) QtyOk21, SUM(t.QtyOk22 * Qty_WIP) QtyOk22, SUM(t.QtyOk23 * Qty_WIP) QtyOk23, SUM(t.QtyOk24 * Qty_WIP) QtyOk24, SUM(t.QtyOk25 * Qty_WIP) QtyOk25, SUM(t.QtyOk26 * Qty_WIP) QtyOk26, SUM(t.QtyOk27 * Qty_WIP) QtyOk27, SUM(t.QtyOk28 * Qty_WIP) QtyOk28, SUM(t.QtyOk29 * Qty_WIP) QtyOk29, SUM(t.QtyOk30 * Qty_WIP) QtyOk30,
			SUM(t.QtyOk31 * Qty_WIP) QtyOk31,
			SUM(t.QtySp01 * Qty_WIP) QtySp01, SUM(t.QtySp02 * Qty_WIP) QtySp02, SUM(t.QtySp03 * Qty_WIP) QtySp03, SUM(t.QtySp04 * Qty_WIP) QtySp04, SUM(t.QtySp05 * Qty_WIP) QtySp05, SUM(t.QtySp06 * Qty_WIP) QtySp06, SUM(t.QtySp07 * Qty_WIP) QtySp07, SUM(t.QtySp08 * Qty_WIP) QtySp08, SUM(t.QtySp09 * Qty_WIP) QtySp09, SUM(t.QtySp10 * Qty_WIP) QtySp10,
			SUM(t.QtySp11 * Qty_WIP) QtySp11, SUM(t.QtySp12 * Qty_WIP) QtySp12, SUM(t.QtySp13 * Qty_WIP) QtySp13, SUM(t.QtySp14 * Qty_WIP) QtySp14, SUM(t.QtySp15 * Qty_WIP) QtySp15, SUM(t.QtySp16 * Qty_WIP) QtySp16, SUM(t.QtySp17 * Qty_WIP) QtySp17, SUM(t.QtySp18 * Qty_WIP) QtySp18, SUM(t.QtySp19 * Qty_WIP) QtySp19, SUM(t.QtySp20 * Qty_WIP) QtySp20,
			SUM(t.QtySp21 * Qty_WIP) QtySp21, SUM(t.QtySp22 * Qty_WIP) QtySp22, SUM(t.QtySp23 * Qty_WIP) QtySp23, SUM(t.QtySp24 * Qty_WIP) QtySp24, SUM(t.QtySp25 * Qty_WIP) QtySp25, SUM(t.QtySp26 * Qty_WIP) QtySp26, SUM(t.QtySp27 * Qty_WIP) QtySp27, SUM(t.QtySp28 * Qty_WIP) QtySp28, SUM(t.QtySp29 * Qty_WIP) QtySp29, SUM(t.QtySp30 * Qty_WIP) QtySp30,
			SUM(t.QtySp31 * Qty_WIP) QtySp31,
			SUM(case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end) BeratCetak 
		from #Temp t
		outer apply 
		(
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.IDMaterial
			and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')				
		) qwip
		group by t.IDMaterial, t.IDParam, t.NmParam, t.KdMaterial, t.NmMaterial, qwip.Qty_WIP
	end
end

drop table #Temp
END

