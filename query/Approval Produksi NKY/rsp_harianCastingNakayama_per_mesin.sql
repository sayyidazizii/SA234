USE [ISAPabrikProduksi]
GO
/****** Object:  StoredProcedure [dbo].[rsp_harianCastingNakayama_per_mesin]    Script Date: 09/08/2022 08:04:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[rsp_harianCastingNakayama_per_mesin]
 @startdate date,     
 @enddate date,
 @satuan int -- 1 = tonase, 2 = pcs  
as
begin

declare @rawtable table (
    NmMesin varchar(500),
    Approved varchar (max),
    Approvedby varchar (max),
    ApprovedDate varchar (max),
    KdMaterial varchar(500),
    NmMaterial varchar(500),
    tgl int,
    RowIDMaterial uniqueidentifier,
    QtyOk float,
    QtySp float
)

declare @description table (
	NmMesin varchar(500),
	KdMaterial varchar(500),
    NmMaterial varchar(500)
)

declare @total table (
    NmMesin varchar(500),
    KdMaterial varchar(500),
    NmMaterial varchar(500),
    RowIDMaterial uniqueidentifier,
    tgl int,
    QtyOk float,
    QtySp float 
)

declare @qtyByBulan table (
	NmMesin varchar(500),
	KdMaterial varchar(500),
    NmMaterial varchar(500),
    QtyOk01 float,
    QtySp01 float,
    QtyOk02 float,
    QtySp02 float,
    QtyOk03 float,
    QtySp03 float,
    QtyOk04 float,
    QtySp04 float,
    QtyOk05 float,
    QtySp05 float,
    QtyOk06 float,
    QtySp06 float,
    QtyOk07 float,
    QtySp07 float,
    QtyOk08 float,
    QtySp08 float,
    QtyOk09 float,
    QtySp09 float,
    QtyOk10 float,
    QtySp10 float,
    QtyOk11 float,
    QtySp11 float,
    QtyOk12 float,
    QtySp12 float,
    QtyOk13 float,
    QtySp13 float,
    QtyOk14 float,
    QtySp14 float,
    QtyOk15 float,
    QtySp15 float,
    QtyOk16 float,
    QtySp16 float,
    QtyOk17 float,
    QtySp17 float,
    QtyOk18 float,
    QtySp18 float,
    QtyOk19 float,
    QtySp19 float,
    QtyOk20 float,
    QtySp20 float,
    QtyOk21 float,
    QtySp21 float,
    QtyOk22 float,
    QtySp22 float,
    QtyOk23 float,
    QtySp23 float,
    QtyOk24 float,
    QtySp24 float,
    QtyOk25 float,
    QtySp25 float,
    QtyOk26 float,
    QtySp26 float,
    QtyOk27 float,
    QtySp27 float,
    QtyOk28 float,
    QtySp28 float,
    QtyOk29 float,
    QtySp29 float,
    QtyOk30 float,
    QtySp30 float,
    QtyOk31 float,
    QtySp31 float
)

insert into @rawtable (
			NmMesin,
			Approved,
			Approvedby,
			ApprovedDate,
			KdMaterial,
			NmMaterial,
			tgl, 
		    RowIDMaterial,
			QtyOk, 
			QtySp)
select proses.NmMesin,proses.Approved,proses.Approvedby,proses.ApprovedDate,material.KdMaterial, material.NmMaterial, proses.tgl, 
       RowID_Material,
       SUM(case when material.QtyOk is null then 0 else material.QtyOk end) QtyOk, 
       SUM(case when QtySp is null then 0 else QtySp end) QtySp
from
(
  select hpwo.Rowid IDHPWO, datepart(day, hpwo.tglproses) tgl,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, m.NmMesin
  from hasilproseswo hpwo
  --left join isapabrik.dbo.Mesin m on hpwo.IDMesin = m.RowID
  left join ISAPabrik.dbo.ProsesMesin pm on hpwo.RowID=pm.RefRowID
  left join ISAPabrik.dbo.Mesin  m on m.RowID=pm.MesinRowID
  where hpwo.idliniproduksi = '6576C124-9EBC-4A49-902F-A0660499DFB9'
  and hpwo.Approved = '1'
        and hpwo.tglproses >= @startdate and hpwo.tglproses <= @enddate
) proses
outer apply
(
  select hpwod.RowiD, mtrl.RowID RowID_Material, mtrl.KdMaterial,mtrl.NmMaterial, hpwod.Qty QtyOk, (hpwod.SPOk + hpwod.SPKropos + hpwod.SPSeting) QtySp
  from hasilproseswodetail hpwod left join isapabrik.dbo.Material mtrl on hpwod.IDMaterial = mtrl.RowID
  where hpwod.IDHPWO = proses.IDHPWO 
) material
group by proses.NmMesin,proses.Approved,proses.Approvedby,proses.ApprovedDate,material.KdMaterial, material.NmMaterial, material.RowID_Material, proses.tgl
order by proses.tgl


insert into @description (NmMesin,KdMaterial, NmMaterial)
select 
    NmMesin,KdMaterial, NmMaterial
from @rawtable
group by NmMesin,KdMaterial, NmMaterial

insert into @total (NmMesin,KdMaterial, NmMaterial, tgl, RowIDMaterial, QtyOk, QtySp)
select 
    NmMesin,KdMaterial, NmMaterial, 0 tgl, RowIDMaterial, sum(QtyOk), sum(QtySp)
from @rawtable
group by NmMesin,KdMaterial, NmMaterial, RowIDMaterial

insert into @qtyByBulan 
select 
    NmMesin,KdMaterial, NmMaterial, 
    SUM( case when tgl = 1 then QtyOk else 0 end),
    SUM( case when tgl = 1 then QtySp else 0 end),
    SUM( case when tgl = 2 then QtyOk else 0 end),
    SUM( case when tgl = 2 then QtySp else 0 end),
    SUM( case when tgl = 3 then QtyOk else 0 end),
    SUM( case when tgl = 3 then QtySp else 0 end),
    SUM( case when tgl = 4 then QtyOk else 0 end),
    SUM( case when tgl = 4 then QtySp else 0 end),
    SUM( case when tgl = 5 then QtyOk else 0 end),
    SUM( case when tgl = 5 then QtySp else 0 end),
    SUM( case when tgl = 6 then QtyOk else 0 end),
    SUM( case when tgl = 6 then QtySp else 0 end),
    SUM( case when tgl = 7 then QtyOk else 0 end),
    SUM( case when tgl = 7 then QtySp else 0 end),
    SUM( case when tgl = 8 then QtyOk else 0 end),
    SUM( case when tgl = 8 then QtySp else 0 end),
    SUM( case when tgl = 9 then QtyOk else 0 end),
    SUM( case when tgl = 9 then QtySp else 0 end),
    SUM( case when tgl = 10 then QtyOk else 0 end),
    SUM( case when tgl = 10 then QtySp else 0 end),
    SUM( case when tgl = 11 then QtyOk else 0 end),
    SUM( case when tgl = 11 then QtySp else 0 end),
    SUM( case when tgl = 12 then QtyOk else 0 end),
    SUM( case when tgl = 12 then QtySp else 0 end),
    SUM( case when tgl = 13 then QtyOk else 0 end),
    SUM( case when tgl = 13 then QtySp else 0 end),
    SUM( case when tgl = 14 then QtyOk else 0 end),
    SUM( case when tgl = 14 then QtySp else 0 end),
    SUM( case when tgl = 15 then QtyOk else 0 end),
    SUM( case when tgl = 15 then QtySp else 0 end),
    SUM( case when tgl = 16 then QtyOk else 0 end),
    SUM( case when tgl = 16 then QtySp else 0 end),
    SUM( case when tgl = 17 then QtyOk else 0 end),
    SUM( case when tgl = 17 then QtySp else 0 end),
    SUM( case when tgl = 18 then QtyOk else 0 end),
    SUM( case when tgl = 18 then QtySp else 0 end),
    SUM( case when tgl = 19 then QtyOk else 0 end),
    SUM( case when tgl = 19 then QtySp else 0 end),
    SUM( case when tgl = 20 then QtyOk else 0 end),
    SUM( case when tgl = 20 then QtySp else 0 end),
    SUM( case when tgl = 21 then QtyOk else 0 end),
    SUM( case when tgl = 21 then QtySp else 0 end),
    SUM( case when tgl = 22 then QtyOk else 0 end),
    SUM( case when tgl = 22 then QtySp else 0 end),
    SUM( case when tgl = 23 then QtyOk else 0 end),
    SUM( case when tgl = 23 then QtySp else 0 end),
    SUM( case when tgl = 24 then QtyOk else 0 end),
    SUM( case when tgl = 24 then QtySp else 0 end),
    SUM( case when tgl = 25 then QtyOk else 0 end),
    SUM( case when tgl = 25 then QtySp else 0 end),
    SUM( case when tgl = 26 then QtyOk else 0 end),
    SUM( case when tgl = 26 then QtySp else 0 end),
    SUM( case when tgl = 27 then QtyOk else 0 end),
    SUM( case when tgl = 27 then QtySp else 0 end),
    SUM( case when tgl = 28 then QtyOk else 0 end),
    SUM( case when tgl = 28 then QtySp else 0 end),
    SUM( case when tgl = 29 then QtyOk else 0 end),
    SUM( case when tgl = 29 then QtySp else 0 end),
    SUM( case when tgl = 30 then QtyOk else 0 end),
    SUM( case when tgl = 30 then QtySp else 0 end),
    SUM( case when tgl = 31 then QtyOk else 0 end),
    SUM( case when tgl = 31 then QtySp else 0 end)
from @rawtable
group by NmMesin,KdMaterial, NmMaterial

if @satuan = 1
begin
	select 
		qbl.nmMesin,qbl.KdMaterial, qbl.nmMaterial,
		qbl.QtyOk01 * Qty_WIP QtyOk01, qbl.QtyOk02 * Qty_WIP QtyOk02, qbl.QtyOk03 * Qty_WIP QtyOk03, qbl.QtyOk04 * Qty_WIP QtyOk04, qbl.QtyOk05 * Qty_WIP QtyOk05, qbl.QtyOk06 * Qty_WIP QtyOk06, qbl.QtyOk07 * Qty_WIP QtyOk07, qbl.QtyOk08 * Qty_WIP QtyOk08, qbl.QtyOk09 * Qty_WIP QtyOk09, qbl.QtyOk10 * Qty_WIP QtyOk10,
		qbl.QtyOk11 * Qty_WIP QtyOk11, qbl.QtyOk12 * Qty_WIP QtyOk12, qbl.QtyOk13 * Qty_WIP QtyOk13, qbl.QtyOk14 * Qty_WIP QtyOk14, qbl.QtyOk15 * Qty_WIP QtyOk15, qbl.QtyOk16 * Qty_WIP QtyOk16, qbl.QtyOk17 * Qty_WIP QtyOk17, qbl.QtyOk18 * Qty_WIP QtyOk18, qbl.QtyOk19 * Qty_WIP QtyOk19, qbl.QtyOk20 * Qty_WIP QtyOk20,
		qbl.QtyOk21 * Qty_WIP QtyOk21, qbl.QtyOk22 * Qty_WIP QtyOk22, qbl.QtyOk23 * Qty_WIP QtyOk23, qbl.QtyOk24 * Qty_WIP QtyOk24, qbl.QtyOk25 * Qty_WIP QtyOk25, qbl.QtyOk26 * Qty_WIP QtyOk26, qbl.QtyOk27 * Qty_WIP QtyOk27, qbl.QtyOk28 * Qty_WIP QtyOk28, qbl.QtyOk29 * Qty_WIP QtyOk29, qbl.QtyOk30 * Qty_WIP QtyOk30,
		qbl.QtyOk31 * Qty_WIP QtyOk31,
		qbl.QtySp01 * Qty_WIP QtySp01, qbl.QtySp02 * Qty_WIP QtySp02, qbl.QtySp03 * Qty_WIP QtySp03, qbl.QtySp04 * Qty_WIP QtySp04, qbl.QtySp05 * Qty_WIP QtySp05, qbl.QtySp06 * Qty_WIP QtySp06, qbl.QtySp07 * Qty_WIP QtySp07, qbl.QtySp08 * Qty_WIP QtySp08, qbl.QtySp09 * Qty_WIP QtySp09, qbl.QtySp10 * Qty_WIP QtySp10,
		qbl.QtySp11 * Qty_WIP QtySp11, qbl.QtySp12 * Qty_WIP QtySp12, qbl.QtySp13 * Qty_WIP QtySp13, qbl.QtySp14 * Qty_WIP QtySp14, qbl.QtySp15 * Qty_WIP QtySp15, qbl.QtySp16 * Qty_WIP QtySp16, qbl.QtySp17 * Qty_WIP QtySp17, qbl.QtySp18 * Qty_WIP QtySp18, qbl.QtySp19 * Qty_WIP QtySp19, qbl.QtySp20 * Qty_WIP QtySp20,
		qbl.QtySp21 * Qty_WIP QtySp21, qbl.QtySp22 * Qty_WIP QtySp22, qbl.QtySp23 * Qty_WIP QtySp23, qbl.QtySp24 * Qty_WIP QtySp24, qbl.QtySp25 * Qty_WIP QtySp25, qbl.QtySp26 * Qty_WIP QtySp26, qbl.QtySp27 * Qty_WIP QtySp27, qbl.QtySp28 * Qty_WIP QtySp28, qbl.QtySp29 * Qty_WIP QtySp29, qbl.QtySp30 * Qty_WIP QtySp30,
		qbl.QtySp31 * Qty_WIP QtySp31,
		case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end BeratCetak, t.QtyOk * qwip.Qty_WIP QtyOkTotal, t.QtySp * qwip.Qty_WIP QtySpTotal
	from @description d join @total t on d.NmMesin = t.NmMesin and d.NmMaterial = t.NmMaterial
		 join @qtyByBulan qbl on d.NmMesin = qbl.NmMesin and d.KdMaterial= qbl.KdMaterial and d.NmMaterial = qbl.NmMaterial
		 outer apply (
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.RowIDMaterial
				and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')
				
								
		) qwip
end
else 
begin
	select 
		qbl.nmMesin,qbl.KdMaterial, qbl.nmMaterial,
		qbl.QtyOk01, qbl.QtyOk02, qbl.QtyOk03, qbl.QtyOk04, qbl.QtyOk05, qbl.QtyOk06, qbl.QtyOk07, qbl.QtyOk08, qbl.QtyOk09, qbl.QtyOk10,
		qbl.QtyOk11, qbl.QtyOk12, qbl.QtyOk13, qbl.QtyOk14, qbl.QtyOk15, qbl.QtyOk16, qbl.QtyOk17, qbl.QtyOk18, qbl.QtyOk19, qbl.QtyOk20,
		qbl.QtyOk21, qbl.QtyOk22, qbl.QtyOk23, qbl.QtyOk24, qbl.QtyOk25, qbl.QtyOk26, qbl.QtyOk27, qbl.QtyOk28, qbl.QtyOk29, qbl.QtyOk30,
		qbl.QtyOk31,
        qbl.QtySp01, qbl.QtySp02, qbl.QtySp03, qbl.QtySp04, qbl.QtySp05, qbl.QtySp06, qbl.QtySp07, qbl.QtySp08, qbl.QtySp09, qbl.QtySp10,
		qbl.QtySp11, qbl.QtySp12, qbl.QtySp13, qbl.QtySp14, qbl.QtySp15, qbl.QtySp16, qbl.QtySp17, qbl.QtySp18, qbl.QtySp19, qbl.QtySp20,
		qbl.QtySp21, qbl.QtySp22, qbl.QtySp23, qbl.QtySp24, qbl.QtySp25, qbl.QtySp26, qbl.QtySp27, qbl.QtySp28, qbl.QtySp29, qbl.QtySp30,
		qbl.QtySp31,
		case when qwip.Qty_WIP is null then 0 else qwip.Qty_WIP end BeratCetak, t.QtyOk QtyOkTotal, t.QtySp QtySpTotal
	from @description d join @total t on d.NmMesin = t.NmMesin and d.NmMaterial = t.NmMaterial
		 join @qtyByBulan qbl on d.NmMesin = qbl.NmMesin and d.KdMaterial= qbl.KdMaterial and d.NmMaterial = qbl.NmMaterial
		 outer apply (
			select Qty Qty_WIP
			from isapabrik.dbo.wip 
			where wip.IDMatWIP = t.RowIDMaterial
				and wip.IDMatBKU IN ('D07690EE-1333-4AF6-97EB-8E0EE67165CA','A7AEE1D9-EDFC-463D-82B4-64E78AF5F7ED','B3A57893-2A45-49C6-8B28-C1CC6DE3A7E4','ACCBFA7F-61BD-4964-AD9D-C4D1AE956379')
				
				
				
		) qwip
end

end