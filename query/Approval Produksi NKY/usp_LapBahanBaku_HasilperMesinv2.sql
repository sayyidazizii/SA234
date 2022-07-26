USE [ISAPabrikProduksi]
GO
/****** Object:  StoredProcedure [dbo].[usp_LapBahanBaku_HasilperMesinv2]    Script Date: 09/08/2022 08:06:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  
              
-- =============================================                
-- Author  : Agus S               
-- Create date : 31 Mei 2016               
-- Description : Laporan Bahan Baku dan Hasil per Mesin Revisi dari usp_LapBahanBaku_HasilperMesin           
-- EXEC [dbo].[usp_LapBahanBaku_HasilperMesinv2]  '2015-12-01', '2015-12-31'            
-- =============================================                
ALTER PROCEDURE [dbo].[usp_LapBahanBaku_HasilperMesinv2]                          
 @startdte date,               
 @enddate date                
AS                
BEGIN                
--Kelompok Mesin NmMesin NmMaterial qty Sat Kotoran alumunium NmMesin NmMaterial qty sat Qty sat Kucu    
declare @IDMelting uniqueidentifier='B2343017-7687-4E30-8823-1C3EE7677C75' --MELTING NAKAYAMA    
declare @IDGravityCasting uniqueidentifier='7D79529F-19C5-4F40-81A6-69521EE30363' --GRAVITY CASTING NAKAYAMA    
declare @IDDieCasting uniqueidentifier='37B0692F-99A7-47C4-9C21-95C9B2A7A9C8' --DIE CASTING NAKAYAMA    
declare @SandCoreCasting uniqueidentifier='39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC' --CASTING SAND CORE NAKAYAMA    
    
declare @inputworkcenter0 uniqueidentifier = 'B2343017-7687-4E30-8823-1C3EE7677C75'               
declare @inputworkcenter1 uniqueidentifier = '7D79529F-19C5-4F40-81A6-69521EE30363'               
declare @inputworkcenter2 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'               
declare @inputworkcenter3 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'               
declare @inputworkcenter4 uniqueidentifier = null               
              
declare @outputworkcenter0 uniqueidentifier ='7D79529F-19C5-4F40-81A6-69521EE30363'                
declare @outputworkcenter1 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'               
declare @outputworkcenter2 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'             
              
declare @bahanbakurowidpengaruhtonnase uniqueidentifier = 'D07690EE-1333-4AF6-97EB-8E0EE67165CA'     
declare @bahanbakuRowIDResin uniqueidentifier = 'F029DA90-C9C0-4F37-8FD4-F0A3606195A5'  -- meterial Resin untuk Proses Produksi Casting sand core          
declare @prosesrowidpengaruhtonnase1 uniqueidentifier = '37B0692F-99A7-47C4-9C21-95C9B2A7A9C8'    -- Proses Produksi DieCasting           
declare @prosesrowidpengaruhtonnase2 uniqueidentifier = '7D79529F-19C5-4F40-81A6-69521EE30363'     -- Proses Produksi GRAVITY CASTING NAKAYAMA            
declare @prosesrowidpengaruhtonnase3 uniqueidentifier = '39B6FD9E-BF9A-4CCC-AB77-E4CA5F2162EC'   -- Proses Produksi Casting sand core          
        
declare @LineProduksiCastingSandCore uniqueidentifier = '6C731B96-86B5-4F45-8CFC-FB0637CE9A46'    

declare @IDMaterialLooping uniqueidentifier  
declare @urutan int
declare @KlpMesin varchar(50)
declare @KlpMesinLooping varchar(50)
declare @PrevRowID uniqueidentifier
declare @RowIDLooping uniqueidentifier
declare @nomor int = 1
declare @BahanBakuLooping uniqueidentifier
declare @TglProsesLooping date
declare @TglProses date

declare @tabelmaterial table(  
IDMaterial uniqueidentifier,  
NmMaterial varchar(50),  
Nama varchar(20)  
) 

declare @tableBahanBaku1 table( 
Nomor int,
TglProses date,
Shift int,
BahanBaku uniqueidentifier,    
KlpMesin varchar(50),     
KdMesin varchar(50),     
NmMesin varchar(50), 
Approved varchar(MAX),
Approvedby varchar(MAX),
ApprovedDate varchar(MAX),   
IDMaterial uniqueidentifier ,     
KdMaterial varchar(50),     
NmMaterial varchar(50),     
Qty  float,     
Satuan varchar(10),
TipeItem tinyint,
urutan int    
)  
  
declare @tabelHasilProduksi1 table(
Nomor int,
TglProses date,
BahanBaku uniqueidentifier,    
KlpMesin varchar(50),     
KdMesin varchar(50),     
NmMesin varchar(50),
Approved varchar(MAX),
Approvedby varchar(MAX),
ApprovedDate varchar(MAX),
IDMaterial uniqueidentifier ,     
KdMaterial varchar(50),     
NmMaterial varchar(50),
Komponen varchar(50),      
sumQty float,    
sumSp float,               
sumQtyKgPcs float,     
sumSPKgPcs float,           
sumKucuKgPcs float,
QtyKomp float,
urutan int    
)    
  
declare @kotAluminium1 table( 
Nomor int,
TglProses date,
BahanBaku uniqueidentifier,     
KlpMesin varchar(50),    
KotoranAlumuniumCair float,
urutan int    
)    

declare @result table(
Nomor int,
TglProses date,
Shift int,
BahanBaku uniqueidentifier,    
KlpMesin varchar(50),     
KdMesin varchar(50),     
NmMesin varchar(50), 
Approved varchar(MAX),
Approvedby varchar(MAX),
ApprovedDate varchar(MAX),      
IDMaterial uniqueidentifier ,     
KdMaterial varchar(50),     
NmMaterial varchar(50),     
Qty  float,     
Satuan varchar(10),
TipeItem tinyint,
BahanBakuHasil uniqueidentifier,  
TglProsesHasil date,  
KlpMesinHasil varchar(50),     
KdMesinHasil varchar(50),     
NmMesinHasil varchar(50),     
IDMaterialHasil uniqueidentifier ,     
KdMaterialHasil varchar(50),     
NmMaterialHasil varchar(50), 
NmKomponen varchar(50),        
sumQty float,    
sumSp float,               
sumQtyKgPcs float,     
sumSPKgPcs float,           
sumKucuKgPcs float,
QtyKomp float,
BahanBakuKot uniqueidentifier,     
KlpMesinKot varchar(50),    
KotoranAlumuniumCair float,
TotalBKU float,
TotalHasil float
)

declare @Sandcore uniqueidentifier = NEWID()
-- Sandcore    
	insert into @tableBahanBaku1    
	select 
		null,
		pb.Tanggal,
		'1', 
		@Sandcore,
		'SandCore' KlpMesin,
		'' KdMesin, 
		'' NmMesin,
		'' Approved,
		'' Approvedby,
		'' ApprovedDate, 
		pbd.MaterialRowID, 
		m.KdMaterial , 
		m.NmMaterial , 
		(pbd.Qty) sumQty , 
		m.Satuan ,
		'0',
		ROW_NUMBER() OVER (Order by @sandcore, pb.Tanggal)        
	from ISAPabrik.dbo.PemakaianBarang pb       
	inner Join ISAPabrik.dbo.PemakaianBarangDetail pbd on pb.RowID = pbd.HeaderRowID              
	left join isapabrik.dbo.material m on m.RowID = pbd.MaterialRowID                 
	where pb.LineProduksiRowID = @LineProduksiCastingSandCore                
	and pb.Tanggal between @startdte and @enddate              

--Output dari hasil Casting   SandCore          
	insert into @tabelHasilProduksi1        
		select null, 
		t.TglProses,
		@Sandcore,
		'SandCore' KlpMesin, 
		t.KdMesin, 
		t.NmMesin, 
		t.Approved,
		t.Approvedby,
		t.ApprovedDate,
		t.IDMaterial, 
		t.KdMaterial, 
		t.NmMaterial,
		null,
		t.sumQty, 
		t.sumSP,       
		t.sumQty * resepkgpcs.kgpcs sumQtyKgPcs , 
		t.sumSp * resepkgpcs.kgpcs sumSPKgPcs ,           
		(isnull(t.sumQty,0) + isnull(t.sumSp,0)) * resepkgpcs.qtykucu  sumKucuKgPcs,
		null,
		ROW_NUMBER() OVER (Order by @sandcore, t.TglProses)             
	from                 
	(                
	 select hpwo.TglProses,msn.KlpMesin, msn.KdMesin, msn.NmMesin,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial , sum(hpwod.Qty) sumQty , sum(hpwod.SPOk) sumSP  , m.Satuan                
	 from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO                 
	 left join isapabrik.dbo.material m on m.RowID = hpwod.IDMaterial       
	 left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID  
	 left join ISAPabrik.dbo.Mesin msn on msn.RowID = pm.MesinRowID            
	 where (       
	  hpwo.ProsesID = @outputworkcenter2        
	 )    
	 --and hpwo.Approved = '1'              
	 and hpwo.TglProses between @startdte and @enddate                 
	 group by hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial  ,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, m.Satuan ,msn.KlpMesin, msn.KdMesin, msn.NmMesin, hpwo.TglProses            
	) t                 
	outer apply                 
	(                
	   select top 1 isnull(subw.Qty,0) kgpcs , ISNULL(subw.QtyKucu,0) qtykucu                  
	   from ISAPabrik.dbo.WIP subw                    
	   where (subw.IDMatBKU  = @bahanbakuRowIDResin)    
	   and subw.IDMatWIP = t.IDMaterial and                 
	   (subw.idproses=@prosesrowidpengaruhtonnase3 )                 
	) resepkgpcs    

--Mencari Material Alumunium Melting  
	insert into @tabelmaterial  
		select distinct 
			hpwod.IDMaterial,   
			m.NmMaterial,  
			case when m.NmMaterial = 'ALUMUNIUM CAIR' then 'OTHER' else RIGHT(m.NmMaterial , (LEN(m.NmMaterial)-charindex('R',m.NmMaterial)-1)) end as Mat  
		from HasilProsesWODetail hpwod  
		inner join HasilProsesWO hpwo on hpwo.RowID = hpwod.IDHPWO  
		join ISAPabrik.dbo.material m on m.RowID = hpwod.IDMaterial  
		where hpwo.ProsesID = @IDMelting  
		--and hpwo.Approved = '1' 
		and hpwod.IDMaterial <> '00000000-0000-0000-0000-000000000000'  
  

--Mulai Perulangan  
 DECLARE Temp_cursor CURSOR FOR        
 SELECT  IDMaterial FROM @tabelmaterial  
 OPEN Temp_cursor;   
   
 FETCH NEXT FROM Temp_cursor INTO @IDMaterialLooping ;  
 WHILE @@FETCH_STATUS = 0        
 BEGIN  

	  insert into @tableBahanBaku1
	  select
		  null, 
		  hpwo.TglProses,
		  hpwo.Shift,
		  hpwod.IDMaterial BahanBaku,
		  msn.KlpMesin, 
		  msn.KdMesin, 
		  msn.NmMesin,
		  hpwo.Approved,
		  hpwo.Approvedby,
		  hpwo.ApprovedDate, 
		  hpwokd.IDMaterial , 
		  m.KdMaterial , 
		  m.NmMaterial , 
		  (hpwokd.Qty +hpwokd.SP) sumQty , 
		  m.Satuan,
		  hpwokd.TipeItem,
		  ROW_NUMBER() OVER (ORDER BY hpwod.IDMaterial, msn.KlpMesin,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate, hpwo.TglProses, hpwo.Shift)        
	  from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO                 
	  left join HasilProsesWOKDetail hpwokd on hpwokd.IDHPWOD = hpwod.RowID                 
	  left join isapabrik.dbo.material m on m.RowID = hpwokd.IDMaterial    
	  left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID  
	  left join ISAPabrik.dbo.Mesin msn on msn.RowID = pm.MesinRowID              
	  where hpwo.ProsesID = @IDMelting  
	  --and hpwo.Approved = '1'          
	  and hpwo.TglProses between @startdte and @enddate      
	  AND hpwod.IDMaterial= @IDMaterialLooping   
	 
	  insert into @tabelHasilProduksi1
	  select 
		  null,
		  t.TglProses,
		  resepkgpcs.IDMatBKU,
		  t.KlpMesin, 
		  t.KdMesin, 
		  t.NmMesin, 
		  t.Approved,
		  t.Approvedby,
		  t.ApprovedDate,
		  t.IDMaterial, 
		  t.KdMaterial, 
		  t.NmMaterial, 
		  x.NmMaterial, 
		  t.sumQty, 
		  t.sumSP,               
		  t.sumQty * resepkgpcs.kgpcs sumQtyKgPcs , 
		  t.sumSp * resepkgpcs.kgpcs sumSPKgPcs ,    
		  (isnull(t.sumQty,0) + isnull(t.sumSp,0)) * resepkgpcs.qtykucu  sumKucuKgPcs,
		  x.Qty,
		  ROW_NUMBER() OVER (ORDER BY resepkgpcs.IDMatBKU, t.KlpMesin)             
	  from                 
	  (                
	   select hpwo.TglProses,mesn.KlpMesin, mesn.KdMesin, mesn.NmMesin ,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate,hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial , sum(hpwod.Qty) sumQty , sum(hpwod.SPOk) sumSP  , m.Satuan               
	   from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO                 
	   left join isapabrik.dbo.material m on m.RowID = hpwod.IDMaterial       
	   left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID  
	   left join ISAPabrik.dbo.Mesin mesn on mesn.RowID = pm.MesinRowID              
	   where (       
	   hpwo.ProsesID = @outputworkcenter0 or hpwo.ProsesID = @outputworkcenter1 
	--and hpwo.Approved = '1'    
	   )                 
	   and hpwo.TglProses between @startdte and @enddate                 
	   group by hpwod.IDMaterial  , m.KdMaterial , m.NmMaterial ,hpwo.Approved,hpwo.Approvedby,hpwo.ApprovedDate , m.Satuan , mesn.KlpMesin, mesn.KdMesin, mesn.NmMesin, hpwo.TglProses              
	  ) t                 
	  outer apply                 
	  (                
		 select top 1 isnull(subw.Qty,0) kgpcs , ISNULL(subw.QtyKucu,0) qtykucu, subw.IDMatBKU                 
		 from ISAPabrik.dbo.WIP subw                    
		 where (subw.IDMatBKU = @IDMaterialLooping
		 and subw.IDMatWIP = t.IDMaterial and                 
		 ( subw.IDProses = @prosesrowidpengaruhtonnase1 or subw.idproses=@prosesrowidpengaruhtonnase2 or subw.idproses = @prosesrowidpengaruhtonnase3 ))             
	  ) resepkgpcs 
	  outer apply
	  (
		select top 1 hpwokd.IDMaterial, m.NmMaterial, SUM(hpwokd.Qty) Qty
		from HasilProsesWO hpwo
		join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO
		join HasilProsesWOKDetail hpwokd on hpwo.RowID = hpwokd.IDHPWO and hpwokd.IDHPWOD = hpwod.RowID
		join Isapabrik.dbo.Material m on m.RowID = hpwokd.IDMaterial
		where hpwokd.TipeItem = 1
		--and hpwo.Approved = '1' 
		and hpwo.TglProses = t.TglProses
		and hpwod.IDMaterial = t.IDMaterial
		and (hpwo.ProsesID = @IDGravityCasting or hpwo.ProsesID = @IDDieCasting)
		group by hpwo.TglProses, hpwokd.IDMaterial, m.NmMaterial
	  )x                   
	  where ISNULL(resepkgpcs.kgpcs,0) >0 
	  
	  insert into @kotAluminium1 
	  select
		  null,
		  hpwo.TglProses,
		  hpwod.IDMaterial, 
		  KlpMesin, 
		  SUM(hpwod.SPOK) KotoranAlumuniumCair,
		  ROW_NUMBER() OVER (ORDER BY hpwod.IDMaterial, msn.KlpMesin)                
	  from HasilProsesWO hpwo inner join HasilProsesWODetail hpwod on hpwo.RowID = hpwod.IDHPWO     
	  left join ISAPabrik.dbo.ProsesMesin pm on pm.RefRowID = hpwo.RowID       
	  left join ISAPabrik.dbo.Mesin msn on pm.MesinRowID=msn.RowID          
	  where hpwo.TglProses between @startdte and @enddate   
	  --and hpwo.Approved = '1'              
	  and (hpwod.IDMaterial = @IDMaterialLooping)  
	  Group by KlpMesin, hpwod.IDMaterial, hpwo.TglProses    
	  order by KlpMesin 
  
 FETCH NEXT FROM Temp_cursor INTO @IDMaterialLooping ;  
 END        
 CLOSE Temp_cursor;        
 DEALLOCATE Temp_cursor; 

set @RowIDLooping = null 

	 DECLARE Nomor_Cur CURSOR FOR 
	 SELECT  BahanBaku, ISNULL(KlpMesin,''), Urutan, TglProses FROM @tableBahanBaku1
	 OPEN Nomor_Cur; 

	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 WHILE @@FETCH_STATUS = 0      
	 BEGIN 
	 
	 select @PrevRowID = BahanBaku, @KlpMesin = ISNULL(KlpMesin,''), @TglProses = TglProses 
	 from @tableBahanBaku1 where urutan = @urutan -1 and BahanBaku = @RowIDLooping
	 
	 IF (@KlpMesinLooping = @KlpMesin and @TglProsesLooping = @TglProses)
	 BEGIN
		set @nomor = @nomor +1
		update @tableBahanBaku1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 ELSE
	 BEGIN
		set @nomor = 1
		update @tableBahanBaku1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 
	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 END      
	 CLOSE Nomor_Cur;      
	 DEALLOCATE Nomor_Cur;
	 
set @RowIDLooping = null 
set @nomor = 0
set @TglProses = '1990-01-01'
set @TglProsesLooping = '1990-01-01'

	 DECLARE Nomor_Cur CURSOR FOR 
	 SELECT  BahanBaku, ISNULL(KlpMesin,''), Urutan, TglProses FROM @tabelHasilProduksi1
	 OPEN Nomor_Cur; 

	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 WHILE @@FETCH_STATUS = 0      
	 BEGIN 
	 
	 select @PrevRowID = BahanBaku, @KlpMesin = ISNULL(KlpMesin,''), @TglProses = TglProses 
	 from @tabelHasilProduksi1 where urutan = @urutan -1 and BahanBaku = @RowIDLooping
	 
	 IF (@KlpMesinLooping = @KlpMesin and @TglProsesLooping = @TglProses)
	 BEGIN
		set @nomor = @nomor +1
		update @tabelHasilProduksi1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 ELSE
	 BEGIN
		set @nomor = 1
		update @tabelHasilProduksi1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 
	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 END      
	 CLOSE Nomor_Cur;      
	 DEALLOCATE Nomor_Cur;
	 
set @RowIDLooping = null 
set @nomor = 0
set @TglProses = '1990-01-01'
set @TglProsesLooping = '1990-01-01'

	 DECLARE Nomor_Cur CURSOR FOR 
	 SELECT  BahanBaku, ISNULL(KlpMesin,''), Urutan, TglProses FROM @kotAluminium1
	 OPEN Nomor_Cur; 

	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 WHILE @@FETCH_STATUS = 0      
	 BEGIN 
	 
	 select @PrevRowID = BahanBaku, @KlpMesin = ISNULL(KlpMesin,''), @TglProses = TglProses  
	 from @kotAluminium1 where urutan = @urutan -1 and BahanBaku = @RowIDLooping
	 
	 IF (@KlpMesinLooping = @KlpMesin and @TglProsesLooping = @TglProses)
	 BEGIN
		set @nomor = @nomor +1
		update @kotAluminium1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 ELSE
	 BEGIN
		set @nomor = 1
		update @kotAluminium1 set Nomor = @nomor 
		where Urutan = @urutan 
		and BahanBaku = @RowIDLooping
	 END
	 
	 FETCH NEXT FROM Nomor_Cur INTO @RowIDLooping, @KlpMesinLooping, @urutan, @TglProsesLooping;
	 END      
	 CLOSE Nomor_Cur;      
	 DEALLOCATE Nomor_Cur;
	
insert @result (Nomor, BahanBaku, KlpMesin, TglProses,Approved ,Approvedby,ApprovedDate)
select distinct Nomor, BahanBaku, KlpMesin, TglProses ,Approved ,Approvedby,ApprovedDate  from @tableBahanBaku1 
union
select distinct Nomor, BahanBaku, KlpMesin, TglProses,Approved ,Approvedby,ApprovedDate  from @tabelHasilProduksi1

-------------------------------------
--Penggabungan data untuk laporan
	 set @TglProsesLooping = '1990-01-01'	
	 set @KlpMesinLooping = '' 
	 
	 --select * from @result order by BahanBaku, Nomor
	 --select * from @tableBahanBaku1
	 
	 DECLARE end_cur CURSOR FOR
	 select distinct BahanBaku, ISNULL(KlpMesin,''), TglProses from @tableBahanBaku1 
	 union
	 select distinct BahanBaku, ISNULL(KlpMesin,''), TglProses from @tabelHasilProduksi1
	 
	 open end_cur 
	 fetch next from end_cur into @BahanBakuLooping,  @KlpMesinLooping, @TglProsesLooping
	 
	 while @@FETCH_STATUS = 0
	 begin
		update @result set
			Shift = r.Shift,    
			KdMesin = r.KdMesin,     
			NmMesin = r.NmMesin,    
			IDMaterial  = r.IDMaterial,     
			KdMaterial = r.KdMaterial,     
			NmMaterial = r.NmMaterial,     
			Qty  = r.Qty,     
			Satuan = r.Satuan,
			TipeItem = r.TipeItem
			from (
		select 
			Nomor Nmr,
			TglProses TglBhnBku,
			Shift ,
			BahanBaku BhnBku,    
			KlpMesin KlpMesinBku,     
			KdMesin ,     
			NmMesin ,    
			IDMaterial  ,     
			KdMaterial ,     
			NmMaterial ,     
			Qty  ,     
			Satuan ,
			TipeItem
		from @tableBahanBaku1 r
		where r.BahanBaku = @BahanBakuLooping and ISNULL(r.KlpMesin,'') = @KlpMesinLooping
		) r where (r.BhnBku = BahanBaku and r.Nmr = Nomor and r.TglBhnBku = TglProses and ISNULL(r.KlpMesinBku,'') = isnull(KlpMesin,''))
		
		update @result set
		BahanBakuHasil = r.BahanBakuHasil,
		TglProsesHasil = r.TglHasil,    
		KlpMesinHasil = r.KlpMesinHasil,     
		KdMesinHasil = r.KdMesin,     
		NmMesinHasil = r.NmMesin,     
		IDMaterialHasil  = r.IDMaterial,     
		KdMaterialHasil = r.KdMaterial,     
		NmMaterialHasil = r.NmMaterial, 
		NmKomponen = r.Komponen,     
		sumQty = r.sumQty,    
		sumSp = r.sumSp,               
		sumQtyKgPcs = r.sumQtyKgPcs,     
		sumSPKgPcs = r.sumSPKgPcs,           
		sumKucuKgPcs = r.sumKucuKgPcs,
		QtyKomp = r.QtyKomp
		from (
			select 
				Nomor NoHasil,
				TglProses TglHasil,
				BahanBaku BahanBakuHasil,    
				KlpMesin KlpMesinHasil,     
				KdMesin ,     
				NmMesin ,     
				IDMaterial  ,     
				KdMaterial ,     
				NmMaterial ,
				Komponen,      
				sumQty ,    
				sumSp ,               
				sumQtyKgPcs ,     
				sumSPKgPcs ,           
				sumKucuKgPcs,
				QtyKomp 
			from  @tabelHasilProduksi1 r
			where BahanBaku = @BahanBakuLooping and ISNULL(KlpMesin,'') = @KlpMesinLooping
		)r where (r.BahanBakuHasil = BahanBaku and Nomor = r.NoHasil and ISNULL(r.KlpMesinHasil,'')=ISNULL(KlpMesin,'') and r.TglHasil = TglProses)
	 
	 	update @result set
		BahanBakuKot = r.BahanBakuKot,    
		KlpMesinKot = r.KlpMesinKot,     
		KotoranAlumuniumCair = r.KotoranAlumuniumCair    
		from (
			select 
				Nomor NoKot,
				TglProses TglProsesKot,
				BahanBaku BahanBakuKot,    
				KlpMesin KlpMesinKot,     
				KotoranAlumuniumCair    
			from  @kotAluminium1 r
			where BahanBaku = @BahanBakuLooping and ISNULL(KlpMesin,'') = @KlpMesinLooping
		)r where (r.BahanBakuKot = BahanBaku and Nomor = r.NoKot and ISNULL(r.KlpMesinKot,'')=ISNULL(KlpMesin,'') and r.TglProsesKot = TglProsesHasil)
		
		update @result set
		TotalBKU = r.TotQty
		from(
			 select 
			 BahanBaku BhanBakuTot,
			 TglProses TglProsesTot,
			 KlpMesin KlpMesinTot,
			 SUM(Qty) TotQty from @tableBahanBaku1
			 where TipeItem = 0
			 group by BahanBaku, KlpMesin, TipeItem, TglProses
		)r where (r.BhanBakuTot = BahanBaku and ISNULL(r.KlpMesinTot,'')=ISNULL(KlpMesin,'') and Nomor = '1' and r.TglProsesTot = TglProses)
		
		update @result set
		TotalHasil = r.Qty
		from (
		select 
		TglProses Tgl, 
		BahanBaku BhnBku, 
		KlpMesin KlpMsn, 
		SUM(sumQtyKgPcs + sumSPKgPcs + sumKucuKgPcs) Qty from @tabelHasilProduksi1
		group by BahanBaku, TglProses, KlpMesin
		)r where (r.BhnBku = BahanBaku and ISNULL(r.KlpMsn,'') = ISNULL(KlpMesin,'') and r.Tgl = TglProses and Nomor = '1')

		 
		fetch next from end_cur into @BahanBakuLooping,  @KlpMesinLooping, @TglProsesLooping
	 end
	 
	 close end_cur 
	 deallocate end_cur 
	 
	 -------------------------------------------------
	 ------Menampilkan Data 
	 select 
	 m.KdMaterial Kode,
	 m.NmMaterial Nama, 
	 r.TglProses,
	 r.Shift,
	 r.BahanBaku,
	 r.KdMesin,
	 r.NmMesin,
	 r.Approved,
	 r.Approvedby,
	 r.ApprovedDate,
	 r.KdMaterial,
	 r.NmMaterial,
	 r.Qty,
	 r.Satuan,
	 r.KotoranAlumuniumCair,
	 r.BahanBakuHasil,
	 r.KdMesinHasil,
	 r.NmMesinHasil,
	 r.KdMaterialHasil,
	 r.NmMaterialHasil,
	 r.NmKomponen,
	 r.sumQty,
	 r.sumSp,
	 r.sumQtyKgPcs,
	 r.sumSPKgPcs,
	 r.sumKucuKgPcs,
	 r.QtyKomp,
	 r.TotalBKU,
	 r.TotalHasil + r.KotoranAlumuniumCair TotalHasil,
	 ISNULL(r.TotalBKU,0) - (ISNULL(r.TotalHasil,0) + ISNULL(r.KotoranAlumuniumCair,0)) Selisih,
	 ((ISNULL(r.TotalBKU,0) - (ISNULL(r.TotalHasil,0)+ ISNULL(r.KotoranAlumuniumCair,0))) / r.TotalBKU * 100) [Selisih%]
	 from @result r
	 left join Isapabrik.dbo.Material m on m.RowID = r.BahanBaku
	  where r.Approved = '1'
	 order by m.NmMaterial, TglProses, KlpMesin, Nomor
END   

