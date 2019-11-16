open Prims
let subst_to_string :
  'Auu____4 . (FStar_Syntax_Syntax.bv * 'Auu____4) Prims.list -> Prims.string
  =
  fun s  ->
    let uu____23 =
      FStar_All.pipe_right s
        (FStar_List.map
           (fun uu____44  ->
              match uu____44 with
              | (b,uu____51) ->
                  (b.FStar_Syntax_Syntax.ppname).FStar_Ident.idText))
       in
    FStar_All.pipe_right uu____23 (FStar_String.concat ", ")
  
let rec apply_until_some :
  'Auu____66 'Auu____67 .
    ('Auu____66 -> 'Auu____67 FStar_Pervasives_Native.option) ->
      'Auu____66 Prims.list ->
        ('Auu____66 Prims.list * 'Auu____67) FStar_Pervasives_Native.option
  =
  fun f  ->
    fun s  ->
      match s with
      | [] -> FStar_Pervasives_Native.None
      | s0::rest ->
          let uu____109 = f s0  in
          (match uu____109 with
           | FStar_Pervasives_Native.None  -> apply_until_some f rest
           | FStar_Pervasives_Native.Some st ->
               FStar_Pervasives_Native.Some (rest, st))
  
let map_some_curry :
  'Auu____142 'Auu____143 'Auu____144 .
    ('Auu____142 -> 'Auu____143 -> 'Auu____144) ->
      'Auu____144 ->
        ('Auu____142 * 'Auu____143) FStar_Pervasives_Native.option ->
          'Auu____144
  =
  fun f  ->
    fun x  ->
      fun uu___0_171  ->
        match uu___0_171 with
        | FStar_Pervasives_Native.None  -> x
        | FStar_Pervasives_Native.Some (a,b) -> f a b
  
let apply_until_some_then_map :
  'Auu____207 'Auu____208 'Auu____209 .
    ('Auu____207 -> 'Auu____208 FStar_Pervasives_Native.option) ->
      'Auu____207 Prims.list ->
        ('Auu____207 Prims.list -> 'Auu____208 -> 'Auu____209) ->
          'Auu____209 -> 'Auu____209
  =
  fun f  ->
    fun s  ->
      fun g  ->
        fun t  ->
          let uu____257 = apply_until_some f s  in
          FStar_All.pipe_right uu____257 (map_some_curry g t)
  
let compose_subst :
  'Auu____283 .
    ('Auu____283 Prims.list * FStar_Syntax_Syntax.maybe_set_use_range) ->
      ('Auu____283 Prims.list * FStar_Syntax_Syntax.maybe_set_use_range) ->
        ('Auu____283 Prims.list * FStar_Syntax_Syntax.maybe_set_use_range)
  =
  fun s1  ->
    fun s2  ->
      let s =
        FStar_List.append (FStar_Pervasives_Native.fst s1)
          (FStar_Pervasives_Native.fst s2)
         in
      let ropt =
        match FStar_Pervasives_Native.snd s2 with
        | FStar_Syntax_Syntax.SomeUseRange uu____334 ->
            FStar_Pervasives_Native.snd s2
        | uu____337 -> FStar_Pervasives_Native.snd s1  in
      (s, ropt)
  
let (delay :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
      FStar_Syntax_Syntax.maybe_set_use_range) -> FStar_Syntax_Syntax.term)
  =
  fun t  ->
    fun s  ->
      match t.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_delayed ((t',s'),m) ->
          FStar_Syntax_Syntax.mk_Tm_delayed (t', (compose_subst s' s))
            t.FStar_Syntax_Syntax.pos
      | uu____420 ->
          FStar_Syntax_Syntax.mk_Tm_delayed (t, s) t.FStar_Syntax_Syntax.pos
  
let rec (force_uvar' :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * Prims.bool))
  =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_uvar
        ({ FStar_Syntax_Syntax.ctx_uvar_head = uv;
           FStar_Syntax_Syntax.ctx_uvar_gamma = uu____446;
           FStar_Syntax_Syntax.ctx_uvar_binders = uu____447;
           FStar_Syntax_Syntax.ctx_uvar_typ = uu____448;
           FStar_Syntax_Syntax.ctx_uvar_reason = uu____449;
           FStar_Syntax_Syntax.ctx_uvar_should_check = uu____450;
           FStar_Syntax_Syntax.ctx_uvar_range = uu____451;
           FStar_Syntax_Syntax.ctx_uvar_meta = uu____452;_},s)
        ->
        let uu____501 = FStar_Syntax_Unionfind.find uv  in
        (match uu____501 with
         | FStar_Pervasives_Native.Some t' ->
             let uu____512 =
               let uu____515 =
                 let uu____523 = delay t' s  in force_uvar' uu____523  in
               FStar_Pervasives_Native.fst uu____515  in
             (uu____512, true)
         | uu____533 -> (t, false))
    | uu____540 -> (t, false)
  
let (force_uvar :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun t  ->
    let uu____557 = force_uvar' t  in
    match uu____557 with
    | (t',forced) ->
        if forced
        then
          delay t'
            ([],
              (FStar_Syntax_Syntax.SomeUseRange (t.FStar_Syntax_Syntax.pos)))
        else t
  
let rec (try_read_memo_aux :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax * Prims.bool))
  =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_delayed (f,m) ->
        let uu____648 = FStar_ST.op_Bang m  in
        (match uu____648 with
         | FStar_Pervasives_Native.None  -> (t, false)
         | FStar_Pervasives_Native.Some t' ->
             let uu____698 = try_read_memo_aux t'  in
             (match uu____698 with
              | (t'1,shorten) ->
                  (if shorten
                   then
                     FStar_ST.op_Colon_Equals m
                       (FStar_Pervasives_Native.Some t'1)
                   else ();
                   (t'1, true))))
    | uu____758 -> (t, false)
  
let (try_read_memo :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun t  ->
    let uu____775 = try_read_memo_aux t  in
    FStar_Pervasives_Native.fst uu____775
  
let rec (compress_univ :
  FStar_Syntax_Syntax.universe -> FStar_Syntax_Syntax.universe) =
  fun u  ->
    match u with
    | FStar_Syntax_Syntax.U_unif u' ->
        let uu____801 = FStar_Syntax_Unionfind.univ_find u'  in
        (match uu____801 with
         | FStar_Pervasives_Native.Some u1 -> compress_univ u1
         | uu____805 -> u)
    | uu____808 -> u
  
let (subst_bv :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.subst_elt Prims.list ->
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun a  ->
    fun s  ->
      FStar_Util.find_map s
        (fun uu___1_830  ->
           match uu___1_830 with
           | FStar_Syntax_Syntax.DB (i,x) when
               i = a.FStar_Syntax_Syntax.index ->
               let uu____838 =
                 let uu____839 =
                   let uu____840 = FStar_Syntax_Syntax.range_of_bv a  in
                   FStar_Syntax_Syntax.set_range_of_bv x uu____840  in
                 FStar_Syntax_Syntax.bv_to_name uu____839  in
               FStar_Pervasives_Native.Some uu____838
           | uu____841 -> FStar_Pervasives_Native.None)
  
let (subst_nm :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.subst_elt Prims.list ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax
        FStar_Pervasives_Native.option)
  =
  fun a  ->
    fun s  ->
      FStar_Util.find_map s
        (fun uu___2_867  ->
           match uu___2_867 with
           | FStar_Syntax_Syntax.NM (x,i) when FStar_Syntax_Syntax.bv_eq a x
               ->
               let uu____876 =
                 FStar_Syntax_Syntax.bv_to_tm
                   (let uu___108_881 = a  in
                    {
                      FStar_Syntax_Syntax.ppname =
                        (uu___108_881.FStar_Syntax_Syntax.ppname);
                      FStar_Syntax_Syntax.index = i;
                      FStar_Syntax_Syntax.sort =
                        (uu___108_881.FStar_Syntax_Syntax.sort)
                    })
                  in
               FStar_Pervasives_Native.Some uu____876
           | FStar_Syntax_Syntax.NT (x,t) when FStar_Syntax_Syntax.bv_eq a x
               -> FStar_Pervasives_Native.Some t
           | uu____892 -> FStar_Pervasives_Native.None)
  
let (subst_univ_bv :
  Prims.int ->
    FStar_Syntax_Syntax.subst_elt Prims.list ->
      FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option)
  =
  fun x  ->
    fun s  ->
      FStar_Util.find_map s
        (fun uu___3_917  ->
           match uu___3_917 with
           | FStar_Syntax_Syntax.UN (y,t) when x = y ->
               FStar_Pervasives_Native.Some t
           | uu____925 -> FStar_Pervasives_Native.None)
  
let (subst_univ_nm :
  FStar_Syntax_Syntax.univ_name ->
    FStar_Syntax_Syntax.subst_elt Prims.list ->
      FStar_Syntax_Syntax.universe FStar_Pervasives_Native.option)
  =
  fun x  ->
    fun s  ->
      FStar_Util.find_map s
        (fun uu___4_946  ->
           match uu___4_946 with
           | FStar_Syntax_Syntax.UD (y,i) when
               x.FStar_Ident.idText = y.FStar_Ident.idText ->
               FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.U_bvar i)
           | uu____954 -> FStar_Pervasives_Native.None)
  
let rec (subst_univ :
  FStar_Syntax_Syntax.subst_elt Prims.list Prims.list ->
    FStar_Syntax_Syntax.universe -> FStar_Syntax_Syntax.universe)
  =
  fun s  ->
    fun u  ->
      let u1 = compress_univ u  in
      match u1 with
      | FStar_Syntax_Syntax.U_bvar x ->
          apply_until_some_then_map (subst_univ_bv x) s subst_univ u1
      | FStar_Syntax_Syntax.U_name x ->
          apply_until_some_then_map (subst_univ_nm x) s subst_univ u1
      | FStar_Syntax_Syntax.U_zero  -> u1
      | FStar_Syntax_Syntax.U_unknown  -> u1
      | FStar_Syntax_Syntax.U_unif uu____982 -> u1
      | FStar_Syntax_Syntax.U_succ u2 ->
          let uu____992 = subst_univ s u2  in
          FStar_Syntax_Syntax.U_succ uu____992
      | FStar_Syntax_Syntax.U_max us ->
          let uu____996 = FStar_List.map (subst_univ s) us  in
          FStar_Syntax_Syntax.U_max uu____996
  
let tag_with_range :
  'Auu____1006 .
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      ('Auu____1006 * FStar_Syntax_Syntax.maybe_set_use_range) ->
        FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax
  =
  fun t  ->
    fun s  ->
      match FStar_Pervasives_Native.snd s with
      | FStar_Syntax_Syntax.NoUseRange  -> t
      | FStar_Syntax_Syntax.SomeUseRange r ->
          let uu____1032 =
            let uu____1034 = FStar_Range.use_range t.FStar_Syntax_Syntax.pos
               in
            let uu____1035 = FStar_Range.use_range r  in
            FStar_Range.rng_included uu____1034 uu____1035  in
          if uu____1032
          then t
          else
            (let r1 =
               let uu____1042 = FStar_Range.use_range r  in
               FStar_Range.set_use_range t.FStar_Syntax_Syntax.pos uu____1042
                in
             let t' =
               match t.FStar_Syntax_Syntax.n with
               | FStar_Syntax_Syntax.Tm_bvar bv ->
                   let uu____1045 = FStar_Syntax_Syntax.set_range_of_bv bv r1
                      in
                   FStar_Syntax_Syntax.Tm_bvar uu____1045
               | FStar_Syntax_Syntax.Tm_name bv ->
                   let uu____1047 = FStar_Syntax_Syntax.set_range_of_bv bv r1
                      in
                   FStar_Syntax_Syntax.Tm_name uu____1047
               | FStar_Syntax_Syntax.Tm_fvar fv ->
                   let l = FStar_Syntax_Syntax.lid_of_fv fv  in
                   let v1 =
                     let uu___160_1053 = fv.FStar_Syntax_Syntax.fv_name  in
                     let uu____1054 = FStar_Ident.set_lid_range l r1  in
                     {
                       FStar_Syntax_Syntax.v = uu____1054;
                       FStar_Syntax_Syntax.p =
                         (uu___160_1053.FStar_Syntax_Syntax.p)
                     }  in
                   let fv1 =
                     let uu___163_1056 = fv  in
                     {
                       FStar_Syntax_Syntax.fv_name = v1;
                       FStar_Syntax_Syntax.fv_delta =
                         (uu___163_1056.FStar_Syntax_Syntax.fv_delta);
                       FStar_Syntax_Syntax.fv_qual =
                         (uu___163_1056.FStar_Syntax_Syntax.fv_qual)
                     }  in
                   FStar_Syntax_Syntax.Tm_fvar fv1
               | t' -> t'  in
             let uu___168_1058 = t  in
             {
               FStar_Syntax_Syntax.n = t';
               FStar_Syntax_Syntax.pos = r1;
               FStar_Syntax_Syntax.vars =
                 (uu___168_1058.FStar_Syntax_Syntax.vars)
             })
  
let tag_lid_with_range :
  'Auu____1068 .
    FStar_Ident.lident ->
      ('Auu____1068 * FStar_Syntax_Syntax.maybe_set_use_range) ->
        FStar_Ident.lident
  =
  fun l  ->
    fun s  ->
      match FStar_Pervasives_Native.snd s with
      | FStar_Syntax_Syntax.NoUseRange  -> l
      | FStar_Syntax_Syntax.SomeUseRange r ->
          let uu____1088 =
            let uu____1090 =
              let uu____1091 = FStar_Ident.range_of_lid l  in
              FStar_Range.use_range uu____1091  in
            let uu____1092 = FStar_Range.use_range r  in
            FStar_Range.rng_included uu____1090 uu____1092  in
          if uu____1088
          then l
          else
            (let uu____1096 =
               let uu____1097 = FStar_Ident.range_of_lid l  in
               let uu____1098 = FStar_Range.use_range r  in
               FStar_Range.set_use_range uu____1097 uu____1098  in
             FStar_Ident.set_lid_range l uu____1096)
  
let (mk_range :
  FStar_Range.range -> FStar_Syntax_Syntax.subst_ts -> FStar_Range.range) =
  fun r  ->
    fun s  ->
      match FStar_Pervasives_Native.snd s with
      | FStar_Syntax_Syntax.NoUseRange  -> r
      | FStar_Syntax_Syntax.SomeUseRange r' ->
          let uu____1115 =
            let uu____1117 = FStar_Range.use_range r  in
            let uu____1118 = FStar_Range.use_range r'  in
            FStar_Range.rng_included uu____1117 uu____1118  in
          if uu____1115
          then r
          else
            (let uu____1122 = FStar_Range.use_range r'  in
             FStar_Range.set_use_range r uu____1122)
  
let rec (subst' :
  FStar_Syntax_Syntax.subst_ts ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun s  ->
    fun t  ->
      let subst_tail tl1 = subst' (tl1, (FStar_Pervasives_Native.snd s))  in
      match s with
      | ([],FStar_Syntax_Syntax.NoUseRange ) -> t
      | ([]::[],FStar_Syntax_Syntax.NoUseRange ) -> t
      | uu____1243 ->
          let t0 = try_read_memo t  in
          (match t0.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Tm_unknown  -> tag_with_range t0 s
           | FStar_Syntax_Syntax.Tm_constant uu____1251 ->
               tag_with_range t0 s
           | FStar_Syntax_Syntax.Tm_fvar uu____1256 -> tag_with_range t0 s
           | FStar_Syntax_Syntax.Tm_delayed ((t',s'),m) ->
               FStar_Syntax_Syntax.mk_Tm_delayed (t', (compose_subst s' s))
                 t.FStar_Syntax_Syntax.pos
           | FStar_Syntax_Syntax.Tm_bvar a ->
               apply_until_some_then_map (subst_bv a)
                 (FStar_Pervasives_Native.fst s) subst_tail t0
           | FStar_Syntax_Syntax.Tm_name a ->
               apply_until_some_then_map (subst_nm a)
                 (FStar_Pervasives_Native.fst s) subst_tail t0
           | FStar_Syntax_Syntax.Tm_type u ->
               let uu____1325 = mk_range t0.FStar_Syntax_Syntax.pos s  in
               let uu____1326 =
                 let uu____1333 =
                   let uu____1334 =
                     subst_univ (FStar_Pervasives_Native.fst s) u  in
                   FStar_Syntax_Syntax.Tm_type uu____1334  in
                 FStar_Syntax_Syntax.mk uu____1333  in
               uu____1326 FStar_Pervasives_Native.None uu____1325
           | uu____1339 ->
               let uu____1340 = mk_range t.FStar_Syntax_Syntax.pos s  in
               FStar_Syntax_Syntax.mk_Tm_delayed (t0, s) uu____1340)

and (subst_flags' :
  FStar_Syntax_Syntax.subst_ts ->
    FStar_Syntax_Syntax.cflag Prims.list ->
      FStar_Syntax_Syntax.cflag Prims.list)
  =
  fun s  ->
    fun flags  ->
      FStar_All.pipe_right flags
        (FStar_List.map
           (fun uu___5_1352  ->
              match uu___5_1352 with
              | FStar_Syntax_Syntax.DECREASES a ->
                  let uu____1356 = subst' s a  in
                  FStar_Syntax_Syntax.DECREASES uu____1356
              | f -> f))

and (subst_comp_typ' :
  (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    FStar_Syntax_Syntax.comp_typ -> FStar_Syntax_Syntax.comp_typ)
  =
  fun s  ->
    fun t  ->
      match s with
      | ([],FStar_Syntax_Syntax.NoUseRange ) -> t
      | ([]::[],FStar_Syntax_Syntax.NoUseRange ) -> t
      | uu____1384 ->
          let uu___229_1393 = t  in
          let uu____1394 =
            FStar_List.map (subst_univ (FStar_Pervasives_Native.fst s))
              t.FStar_Syntax_Syntax.comp_univs
             in
          let uu____1399 =
            tag_lid_with_range t.FStar_Syntax_Syntax.effect_name s  in
          let uu____1404 = subst' s t.FStar_Syntax_Syntax.result_typ  in
          let uu____1407 =
            FStar_List.map
              (fun uu____1435  ->
                 match uu____1435 with
                 | (t1,imp) ->
                     let uu____1454 = subst' s t1  in
                     let uu____1455 = subst_imp' s imp  in
                     (uu____1454, uu____1455))
              t.FStar_Syntax_Syntax.effect_args
             in
          let uu____1460 = subst_flags' s t.FStar_Syntax_Syntax.flags  in
          {
            FStar_Syntax_Syntax.comp_univs = uu____1394;
            FStar_Syntax_Syntax.effect_name = uu____1399;
            FStar_Syntax_Syntax.result_typ = uu____1404;
            FStar_Syntax_Syntax.effect_args = uu____1407;
            FStar_Syntax_Syntax.flags = uu____1460
          }

and (subst_comp' :
  (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax)
  =
  fun s  ->
    fun t  ->
      match s with
      | ([],FStar_Syntax_Syntax.NoUseRange ) -> t
      | ([]::[],FStar_Syntax_Syntax.NoUseRange ) -> t
      | uu____1491 ->
          (match t.FStar_Syntax_Syntax.n with
           | FStar_Syntax_Syntax.Total (t1,uopt) ->
               let uu____1512 = subst' s t1  in
               let uu____1513 =
                 FStar_Option.map
                   (subst_univ (FStar_Pervasives_Native.fst s)) uopt
                  in
               FStar_Syntax_Syntax.mk_Total' uu____1512 uu____1513
           | FStar_Syntax_Syntax.GTotal (t1,uopt) ->
               let uu____1530 = subst' s t1  in
               let uu____1531 =
                 FStar_Option.map
                   (subst_univ (FStar_Pervasives_Native.fst s)) uopt
                  in
               FStar_Syntax_Syntax.mk_GTotal' uu____1530 uu____1531
           | FStar_Syntax_Syntax.Comp ct ->
               let uu____1539 = subst_comp_typ' s ct  in
               FStar_Syntax_Syntax.mk_Comp uu____1539)

and (subst_imp' :
  (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option)
  =
  fun s  ->
    fun i  ->
      match i with
      | FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta t) ->
          let uu____1557 =
            let uu____1558 = subst' s t  in
            FStar_Syntax_Syntax.Meta uu____1558  in
          FStar_Pervasives_Native.Some uu____1557
      | i1 -> i1

let (shift :
  Prims.int -> FStar_Syntax_Syntax.subst_elt -> FStar_Syntax_Syntax.subst_elt)
  =
  fun n1  ->
    fun s  ->
      match s with
      | FStar_Syntax_Syntax.DB (i,t) -> FStar_Syntax_Syntax.DB ((i + n1), t)
      | FStar_Syntax_Syntax.UN (i,t) -> FStar_Syntax_Syntax.UN ((i + n1), t)
      | FStar_Syntax_Syntax.NM (x,i) -> FStar_Syntax_Syntax.NM (x, (i + n1))
      | FStar_Syntax_Syntax.UD (x,i) -> FStar_Syntax_Syntax.UD (x, (i + n1))
      | FStar_Syntax_Syntax.NT uu____1597 -> s
  
let (shift_subst :
  Prims.int -> FStar_Syntax_Syntax.subst_t -> FStar_Syntax_Syntax.subst_t) =
  fun n1  -> fun s  -> FStar_List.map (shift n1) s 
let shift_subst' :
  'Auu____1624 .
    Prims.int ->
      (FStar_Syntax_Syntax.subst_t Prims.list * 'Auu____1624) ->
        (FStar_Syntax_Syntax.subst_t Prims.list * 'Auu____1624)
  =
  fun n1  ->
    fun s  ->
      let uu____1655 =
        FStar_All.pipe_right (FStar_Pervasives_Native.fst s)
          (FStar_List.map (shift_subst n1))
         in
      (uu____1655, (FStar_Pervasives_Native.snd s))
  
let (subst_binder' :
  (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
      FStar_Pervasives_Native.option) ->
      (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option))
  =
  fun s  ->
    fun uu____1698  ->
      match uu____1698 with
      | (x,imp) ->
          let uu____1725 =
            let uu___288_1726 = x  in
            let uu____1727 = subst' s x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___288_1726.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___288_1726.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____1727
            }  in
          let uu____1730 = subst_imp' s imp  in (uu____1725, uu____1730)
  
let (subst_binders' :
  (FStar_Syntax_Syntax.subst_elt Prims.list Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
      FStar_Pervasives_Native.option) Prims.list ->
      (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option) Prims.list)
  =
  fun s  ->
    fun bs  ->
      FStar_All.pipe_right bs
        (FStar_List.mapi
           (fun i  ->
              fun b  ->
                if i = Prims.int_zero
                then subst_binder' s b
                else
                  (let uu____1836 = shift_subst' i s  in
                   subst_binder' uu____1836 b)))
  
let (subst_binders :
  FStar_Syntax_Syntax.subst_elt Prims.list ->
    FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.binders)
  =
  fun s  ->
    fun bs  -> subst_binders' ([s], FStar_Syntax_Syntax.NoUseRange) bs
  
let subst_arg' :
  'Auu____1875 .
    FStar_Syntax_Syntax.subst_ts ->
      (FStar_Syntax_Syntax.term * 'Auu____1875) ->
        (FStar_Syntax_Syntax.term * 'Auu____1875)
  =
  fun s  ->
    fun uu____1893  ->
      match uu____1893 with
      | (t,imp) -> let uu____1900 = subst' s t  in (uu____1900, imp)
  
let subst_args' :
  'Auu____1907 .
    FStar_Syntax_Syntax.subst_ts ->
      (FStar_Syntax_Syntax.term * 'Auu____1907) Prims.list ->
        (FStar_Syntax_Syntax.term * 'Auu____1907) Prims.list
  = fun s  -> FStar_List.map (subst_arg' s) 
let (subst_pat' :
  (FStar_Syntax_Syntax.subst_t Prims.list *
    FStar_Syntax_Syntax.maybe_set_use_range) ->
    FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t ->
      (FStar_Syntax_Syntax.pat * Prims.int))
  =
  fun s  ->
    fun p  ->
      let rec aux n1 p1 =
        match p1.FStar_Syntax_Syntax.v with
        | FStar_Syntax_Syntax.Pat_constant uu____2001 -> (p1, n1)
        | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
            let uu____2023 =
              FStar_All.pipe_right pats
                (FStar_List.fold_left
                   (fun uu____2085  ->
                      fun uu____2086  ->
                        match (uu____2085, uu____2086) with
                        | ((pats1,n2),(p2,imp)) ->
                            let uu____2182 = aux n2 p2  in
                            (match uu____2182 with
                             | (p3,m) -> (((p3, imp) :: pats1), m))) 
                   ([], n1))
               in
            (match uu____2023 with
             | (pats1,n2) ->
                 ((let uu___325_2256 = p1  in
                   {
                     FStar_Syntax_Syntax.v =
                       (FStar_Syntax_Syntax.Pat_cons
                          (fv, (FStar_List.rev pats1)));
                     FStar_Syntax_Syntax.p =
                       (uu___325_2256.FStar_Syntax_Syntax.p)
                   }), n2))
        | FStar_Syntax_Syntax.Pat_var x ->
            let s1 = shift_subst' n1 s  in
            let x1 =
              let uu___330_2282 = x  in
              let uu____2283 = subst' s1 x.FStar_Syntax_Syntax.sort  in
              {
                FStar_Syntax_Syntax.ppname =
                  (uu___330_2282.FStar_Syntax_Syntax.ppname);
                FStar_Syntax_Syntax.index =
                  (uu___330_2282.FStar_Syntax_Syntax.index);
                FStar_Syntax_Syntax.sort = uu____2283
              }  in
            ((let uu___333_2288 = p1  in
              {
                FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_var x1);
                FStar_Syntax_Syntax.p = (uu___333_2288.FStar_Syntax_Syntax.p)
              }), (n1 + Prims.int_one))
        | FStar_Syntax_Syntax.Pat_wild x ->
            let s1 = shift_subst' n1 s  in
            let x1 =
              let uu___338_2301 = x  in
              let uu____2302 = subst' s1 x.FStar_Syntax_Syntax.sort  in
              {
                FStar_Syntax_Syntax.ppname =
                  (uu___338_2301.FStar_Syntax_Syntax.ppname);
                FStar_Syntax_Syntax.index =
                  (uu___338_2301.FStar_Syntax_Syntax.index);
                FStar_Syntax_Syntax.sort = uu____2302
              }  in
            ((let uu___341_2307 = p1  in
              {
                FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_wild x1);
                FStar_Syntax_Syntax.p = (uu___341_2307.FStar_Syntax_Syntax.p)
              }), (n1 + Prims.int_one))
        | FStar_Syntax_Syntax.Pat_dot_term (x,t0) ->
            let s1 = shift_subst' n1 s  in
            let x1 =
              let uu___348_2325 = x  in
              let uu____2326 = subst' s1 x.FStar_Syntax_Syntax.sort  in
              {
                FStar_Syntax_Syntax.ppname =
                  (uu___348_2325.FStar_Syntax_Syntax.ppname);
                FStar_Syntax_Syntax.index =
                  (uu___348_2325.FStar_Syntax_Syntax.index);
                FStar_Syntax_Syntax.sort = uu____2326
              }  in
            let t01 = subst' s1 t0  in
            ((let uu___352_2332 = p1  in
              {
                FStar_Syntax_Syntax.v =
                  (FStar_Syntax_Syntax.Pat_dot_term (x1, t01));
                FStar_Syntax_Syntax.p = (uu___352_2332.FStar_Syntax_Syntax.p)
              }), n1)
         in
      aux Prims.int_zero p
  
let (push_subst_lcomp :
  FStar_Syntax_Syntax.subst_ts ->
    FStar_Syntax_Syntax.residual_comp FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.residual_comp FStar_Pervasives_Native.option)
  =
  fun s  ->
    fun lopt  ->
      match lopt with
      | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
      | FStar_Pervasives_Native.Some rc ->
          let uu____2358 =
            let uu___359_2359 = rc  in
            let uu____2360 =
              FStar_Util.map_opt rc.FStar_Syntax_Syntax.residual_typ
                (subst' s)
               in
            {
              FStar_Syntax_Syntax.residual_effect =
                (uu___359_2359.FStar_Syntax_Syntax.residual_effect);
              FStar_Syntax_Syntax.residual_typ = uu____2360;
              FStar_Syntax_Syntax.residual_flags =
                (uu___359_2359.FStar_Syntax_Syntax.residual_flags)
            }  in
          FStar_Pervasives_Native.Some uu____2358
  
let (compose_uvar_subst :
  FStar_Syntax_Syntax.ctx_uvar ->
    FStar_Syntax_Syntax.subst_ts ->
      FStar_Syntax_Syntax.subst_ts -> FStar_Syntax_Syntax.subst_ts)
  =
  fun u  ->
    fun s0  ->
      fun s  ->
        let should_retain x =
          FStar_All.pipe_right u.FStar_Syntax_Syntax.ctx_uvar_binders
            (FStar_Util.for_some
               (fun uu____2410  ->
                  match uu____2410 with
                  | (x',uu____2419) -> FStar_Syntax_Syntax.bv_eq x x'))
           in
        let rec aux uu___7_2435 =
          match uu___7_2435 with
          | [] -> []
          | hd_subst::rest ->
              let hd1 =
                FStar_All.pipe_right hd_subst
                  (FStar_List.collect
                     (fun uu___6_2466  ->
                        match uu___6_2466 with
                        | FStar_Syntax_Syntax.NT (x,t) ->
                            let uu____2475 = should_retain x  in
                            if uu____2475
                            then
                              let uu____2480 =
                                let uu____2481 =
                                  let uu____2488 =
                                    delay t
                                      (rest, FStar_Syntax_Syntax.NoUseRange)
                                     in
                                  (x, uu____2488)  in
                                FStar_Syntax_Syntax.NT uu____2481  in
                              [uu____2480]
                            else []
                        | FStar_Syntax_Syntax.NM (x,i) ->
                            let uu____2503 = should_retain x  in
                            if uu____2503
                            then
                              let x_i =
                                FStar_Syntax_Syntax.bv_to_tm
                                  (let uu___386_2511 = x  in
                                   {
                                     FStar_Syntax_Syntax.ppname =
                                       (uu___386_2511.FStar_Syntax_Syntax.ppname);
                                     FStar_Syntax_Syntax.index = i;
                                     FStar_Syntax_Syntax.sort =
                                       (uu___386_2511.FStar_Syntax_Syntax.sort)
                                   })
                                 in
                              let t =
                                subst' (rest, FStar_Syntax_Syntax.NoUseRange)
                                  x_i
                                 in
                              (match t.FStar_Syntax_Syntax.n with
                               | FStar_Syntax_Syntax.Tm_bvar x_j ->
                                   [FStar_Syntax_Syntax.NM
                                      (x, (x_j.FStar_Syntax_Syntax.index))]
                               | uu____2521 ->
                                   [FStar_Syntax_Syntax.NT (x, t)])
                            else []
                        | uu____2526 -> []))
                 in
              let uu____2527 = aux rest  in FStar_List.append hd1 uu____2527
           in
        let uu____2530 =
          aux
            (FStar_List.append (FStar_Pervasives_Native.fst s0)
               (FStar_Pervasives_Native.fst s))
           in
        match uu____2530 with
        | [] -> ([], (FStar_Pervasives_Native.snd s))
        | s' -> ([s'], (FStar_Pervasives_Native.snd s))
  
let rec (push_subst :
  FStar_Syntax_Syntax.subst_ts ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun s  ->
    fun t  ->
      let mk1 t' =
        let uu____2593 = mk_range t.FStar_Syntax_Syntax.pos s  in
        FStar_Syntax_Syntax.mk t' FStar_Pervasives_Native.None uu____2593  in
      match t.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_delayed uu____2596 -> failwith "Impossible"
      | FStar_Syntax_Syntax.Tm_lazy i ->
          (match i.FStar_Syntax_Syntax.lkind with
           | FStar_Syntax_Syntax.Lazy_embedding uu____2625 ->
               let t1 =
                 let uu____2635 =
                   let uu____2644 =
                     FStar_ST.op_Bang FStar_Syntax_Syntax.lazy_chooser  in
                   FStar_Util.must uu____2644  in
                 uu____2635 i.FStar_Syntax_Syntax.lkind i  in
               push_subst s t1
           | uu____2694 -> t)
      | FStar_Syntax_Syntax.Tm_constant uu____2695 -> tag_with_range t s
      | FStar_Syntax_Syntax.Tm_fvar uu____2700 -> tag_with_range t s
      | FStar_Syntax_Syntax.Tm_unknown  -> tag_with_range t s
      | FStar_Syntax_Syntax.Tm_uvar (uv,s0) ->
          let uu____2727 =
            FStar_Syntax_Unionfind.find uv.FStar_Syntax_Syntax.ctx_uvar_head
             in
          (match uu____2727 with
           | FStar_Pervasives_Native.None  ->
               let uu____2732 =
                 let uu___419_2735 = t  in
                 let uu____2738 =
                   let uu____2739 =
                     let uu____2752 = compose_uvar_subst uv s0 s  in
                     (uv, uu____2752)  in
                   FStar_Syntax_Syntax.Tm_uvar uu____2739  in
                 {
                   FStar_Syntax_Syntax.n = uu____2738;
                   FStar_Syntax_Syntax.pos =
                     (uu___419_2735.FStar_Syntax_Syntax.pos);
                   FStar_Syntax_Syntax.vars =
                     (uu___419_2735.FStar_Syntax_Syntax.vars)
                 }  in
               tag_with_range uu____2732 s
           | FStar_Pervasives_Native.Some t1 ->
               push_subst (compose_subst s0 s) t1)
      | FStar_Syntax_Syntax.Tm_type uu____2776 -> subst' s t
      | FStar_Syntax_Syntax.Tm_bvar uu____2777 -> subst' s t
      | FStar_Syntax_Syntax.Tm_name uu____2778 -> subst' s t
      | FStar_Syntax_Syntax.Tm_uinst (t',us) ->
          let us1 =
            FStar_List.map (subst_univ (FStar_Pervasives_Native.fst s)) us
             in
          let uu____2792 = FStar_Syntax_Syntax.mk_Tm_uinst t' us1  in
          tag_with_range uu____2792 s
      | FStar_Syntax_Syntax.Tm_app (t0,args) ->
          let uu____2825 =
            let uu____2826 =
              let uu____2843 = subst' s t0  in
              let uu____2846 = subst_args' s args  in
              (uu____2843, uu____2846)  in
            FStar_Syntax_Syntax.Tm_app uu____2826  in
          mk1 uu____2825
      | FStar_Syntax_Syntax.Tm_ascribed (t0,(annot,topt),lopt) ->
          let annot1 =
            match annot with
            | FStar_Util.Inl t1 ->
                let uu____2947 = subst' s t1  in FStar_Util.Inl uu____2947
            | FStar_Util.Inr c ->
                let uu____2961 = subst_comp' s c  in
                FStar_Util.Inr uu____2961
             in
          let uu____2968 =
            let uu____2969 =
              let uu____2996 = subst' s t0  in
              let uu____2999 =
                let uu____3016 = FStar_Util.map_opt topt (subst' s)  in
                (annot1, uu____3016)  in
              (uu____2996, uu____2999, lopt)  in
            FStar_Syntax_Syntax.Tm_ascribed uu____2969  in
          mk1 uu____2968
      | FStar_Syntax_Syntax.Tm_abs (bs,body,lopt) ->
          let n1 = FStar_List.length bs  in
          let s' = shift_subst' n1 s  in
          let uu____3098 =
            let uu____3099 =
              let uu____3118 = subst_binders' s bs  in
              let uu____3127 = subst' s' body  in
              let uu____3130 = push_subst_lcomp s' lopt  in
              (uu____3118, uu____3127, uu____3130)  in
            FStar_Syntax_Syntax.Tm_abs uu____3099  in
          mk1 uu____3098
      | FStar_Syntax_Syntax.Tm_arrow (bs,comp) ->
          let n1 = FStar_List.length bs  in
          let uu____3174 =
            let uu____3175 =
              let uu____3190 = subst_binders' s bs  in
              let uu____3199 =
                let uu____3202 = shift_subst' n1 s  in
                subst_comp' uu____3202 comp  in
              (uu____3190, uu____3199)  in
            FStar_Syntax_Syntax.Tm_arrow uu____3175  in
          mk1 uu____3174
      | FStar_Syntax_Syntax.Tm_refine (x,phi) ->
          let x1 =
            let uu___466_3228 = x  in
            let uu____3229 = subst' s x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___466_3228.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___466_3228.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____3229
            }  in
          let phi1 =
            let uu____3233 = shift_subst' Prims.int_one s  in
            subst' uu____3233 phi  in
          mk1 (FStar_Syntax_Syntax.Tm_refine (x1, phi1))
      | FStar_Syntax_Syntax.Tm_match (t0,pats) ->
          let t01 = subst' s t0  in
          let pats1 =
            FStar_All.pipe_right pats
              (FStar_List.map
                 (fun uu____3349  ->
                    match uu____3349 with
                    | (pat,wopt,branch) ->
                        let uu____3379 = subst_pat' s pat  in
                        (match uu____3379 with
                         | (pat1,n1) ->
                             let s1 = shift_subst' n1 s  in
                             let wopt1 =
                               match wopt with
                               | FStar_Pervasives_Native.None  ->
                                   FStar_Pervasives_Native.None
                               | FStar_Pervasives_Native.Some w ->
                                   let uu____3410 = subst' s1 w  in
                                   FStar_Pervasives_Native.Some uu____3410
                                in
                             let branch1 = subst' s1 branch  in
                             (pat1, wopt1, branch1))))
             in
          mk1 (FStar_Syntax_Syntax.Tm_match (t01, pats1))
      | FStar_Syntax_Syntax.Tm_let ((is_rec,lbs),body) ->
          let n1 = FStar_List.length lbs  in
          let sn = shift_subst' n1 s  in
          let body1 = subst' sn body  in
          let lbs1 =
            FStar_All.pipe_right lbs
              (FStar_List.map
                 (fun lb  ->
                    let lbt = subst' s lb.FStar_Syntax_Syntax.lbtyp  in
                    let lbd =
                      let uu____3478 =
                        is_rec &&
                          (FStar_Util.is_left lb.FStar_Syntax_Syntax.lbname)
                         in
                      if uu____3478
                      then subst' sn lb.FStar_Syntax_Syntax.lbdef
                      else subst' s lb.FStar_Syntax_Syntax.lbdef  in
                    let lbname =
                      match lb.FStar_Syntax_Syntax.lbname with
                      | FStar_Util.Inl x ->
                          FStar_Util.Inl
                            (let uu___504_3496 = x  in
                             {
                               FStar_Syntax_Syntax.ppname =
                                 (uu___504_3496.FStar_Syntax_Syntax.ppname);
                               FStar_Syntax_Syntax.index =
                                 (uu___504_3496.FStar_Syntax_Syntax.index);
                               FStar_Syntax_Syntax.sort = lbt
                             })
                      | FStar_Util.Inr fv -> FStar_Util.Inr fv  in
                    let uu___509_3498 = lb  in
                    {
                      FStar_Syntax_Syntax.lbname = lbname;
                      FStar_Syntax_Syntax.lbunivs =
                        (uu___509_3498.FStar_Syntax_Syntax.lbunivs);
                      FStar_Syntax_Syntax.lbtyp = lbt;
                      FStar_Syntax_Syntax.lbeff =
                        (uu___509_3498.FStar_Syntax_Syntax.lbeff);
                      FStar_Syntax_Syntax.lbdef = lbd;
                      FStar_Syntax_Syntax.lbattrs =
                        (uu___509_3498.FStar_Syntax_Syntax.lbattrs);
                      FStar_Syntax_Syntax.lbpos =
                        (uu___509_3498.FStar_Syntax_Syntax.lbpos)
                    }))
             in
          mk1 (FStar_Syntax_Syntax.Tm_let ((is_rec, lbs1), body1))
      | FStar_Syntax_Syntax.Tm_meta
          (t0,FStar_Syntax_Syntax.Meta_pattern (bs,ps)) ->
          let uu____3550 =
            let uu____3551 =
              let uu____3558 = subst' s t0  in
              let uu____3561 =
                let uu____3562 =
                  let uu____3583 = FStar_List.map (subst' s) bs  in
                  let uu____3592 =
                    FStar_All.pipe_right ps (FStar_List.map (subst_args' s))
                     in
                  (uu____3583, uu____3592)  in
                FStar_Syntax_Syntax.Meta_pattern uu____3562  in
              (uu____3558, uu____3561)  in
            FStar_Syntax_Syntax.Tm_meta uu____3551  in
          mk1 uu____3550
      | FStar_Syntax_Syntax.Tm_meta
          (t0,FStar_Syntax_Syntax.Meta_monadic (m,t1)) ->
          let uu____3674 =
            let uu____3675 =
              let uu____3682 = subst' s t0  in
              let uu____3685 =
                let uu____3686 =
                  let uu____3693 = subst' s t1  in (m, uu____3693)  in
                FStar_Syntax_Syntax.Meta_monadic uu____3686  in
              (uu____3682, uu____3685)  in
            FStar_Syntax_Syntax.Tm_meta uu____3675  in
          mk1 uu____3674
      | FStar_Syntax_Syntax.Tm_meta
          (t0,FStar_Syntax_Syntax.Meta_monadic_lift (m1,m2,t1)) ->
          let uu____3712 =
            let uu____3713 =
              let uu____3720 = subst' s t0  in
              let uu____3723 =
                let uu____3724 =
                  let uu____3733 = subst' s t1  in (m1, m2, uu____3733)  in
                FStar_Syntax_Syntax.Meta_monadic_lift uu____3724  in
              (uu____3720, uu____3723)  in
            FStar_Syntax_Syntax.Tm_meta uu____3713  in
          mk1 uu____3712
      | FStar_Syntax_Syntax.Tm_quoted (tm,qi) ->
          (match qi.FStar_Syntax_Syntax.qkind with
           | FStar_Syntax_Syntax.Quote_dynamic  ->
               let uu____3748 =
                 let uu____3749 =
                   let uu____3756 = subst' s tm  in (uu____3756, qi)  in
                 FStar_Syntax_Syntax.Tm_quoted uu____3749  in
               mk1 uu____3748
           | FStar_Syntax_Syntax.Quote_static  ->
               let qi1 = FStar_Syntax_Syntax.on_antiquoted (subst' s) qi  in
               mk1 (FStar_Syntax_Syntax.Tm_quoted (tm, qi1)))
      | FStar_Syntax_Syntax.Tm_meta (t1,m) ->
          let uu____3770 =
            let uu____3771 = let uu____3778 = subst' s t1  in (uu____3778, m)
               in
            FStar_Syntax_Syntax.Tm_meta uu____3771  in
          mk1 uu____3770
  
let rec (compress_slow :
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun t  ->
    let t1 = try_read_memo t  in
    let t2 = force_uvar t1  in
    match t2.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_delayed ((t',s),memo) ->
        ((let uu____3845 =
            let uu____3850 = push_subst s t'  in
            FStar_Pervasives_Native.Some uu____3850  in
          FStar_ST.op_Colon_Equals memo uu____3845);
         compress_slow t2)
    | uu____3882 -> t2
  
let (compress : FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) =
  fun t  ->
    match t.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Tm_delayed (uu____3889,uu____3890) ->
        compress_slow t
    | FStar_Syntax_Syntax.Tm_uvar (uu____3927,uu____3928) -> compress_slow t
    | uu____3945 -> t
  
let (subst :
  FStar_Syntax_Syntax.subst_elt Prims.list ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  = fun s  -> fun t  -> subst' ([s], FStar_Syntax_Syntax.NoUseRange) t 
let (set_use_range :
  FStar_Range.range -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun r  ->
    fun t  ->
      let uu____3980 =
        let uu____3981 =
          let uu____3982 =
            let uu____3983 = FStar_Range.use_range r  in
            FStar_Range.set_def_range r uu____3983  in
          FStar_Syntax_Syntax.SomeUseRange uu____3982  in
        ([], uu____3981)  in
      subst' uu____3980 t
  
let (subst_comp :
  FStar_Syntax_Syntax.subst_elt Prims.list ->
    FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.comp)
  = fun s  -> fun t  -> subst_comp' ([s], FStar_Syntax_Syntax.NoUseRange) t 
let (subst_imp :
  FStar_Syntax_Syntax.subst_elt Prims.list ->
    FStar_Syntax_Syntax.aqual -> FStar_Syntax_Syntax.aqual)
  =
  fun s  -> fun imp  -> subst_imp' ([s], FStar_Syntax_Syntax.NoUseRange) imp 
let (closing_subst :
  FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.subst_elt Prims.list) =
  fun bs  ->
    let uu____4044 =
      FStar_List.fold_right
        (fun uu____4071  ->
           fun uu____4072  ->
             match (uu____4071, uu____4072) with
             | ((x,uu____4107),(subst1,n1)) ->
                 (((FStar_Syntax_Syntax.NM (x, n1)) :: subst1),
                   (n1 + Prims.int_one))) bs ([], Prims.int_zero)
       in
    FStar_All.pipe_right uu____4044 FStar_Pervasives_Native.fst
  
let (open_binders' :
  FStar_Syntax_Syntax.binders ->
    (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.subst_t))
  =
  fun bs  ->
    let rec aux bs1 o =
      match bs1 with
      | [] -> ([], o)
      | (x,imp)::bs' ->
          let x' =
            let uu___591_4245 = FStar_Syntax_Syntax.freshen_bv x  in
            let uu____4246 = subst o x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___591_4245.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___591_4245.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____4246
            }  in
          let imp1 = subst_imp o imp  in
          let o1 =
            let uu____4253 = shift_subst Prims.int_one o  in
            (FStar_Syntax_Syntax.DB (Prims.int_zero, x')) :: uu____4253  in
          let uu____4259 = aux bs' o1  in
          (match uu____4259 with | (bs'1,o2) -> (((x', imp1) :: bs'1), o2))
       in
    aux bs []
  
let (open_binders :
  FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.binders) =
  fun bs  ->
    let uu____4320 = open_binders' bs  in
    FStar_Pervasives_Native.fst uu____4320
  
let (open_term' :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.term *
        FStar_Syntax_Syntax.subst_t))
  =
  fun bs  ->
    fun t  ->
      let uu____4342 = open_binders' bs  in
      match uu____4342 with
      | (bs',opening) ->
          let uu____4355 = subst opening t  in (bs', uu____4355, opening)
  
let (open_term :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.term))
  =
  fun bs  ->
    fun t  ->
      let uu____4371 = open_term' bs t  in
      match uu____4371 with | (b,t1,uu____4384) -> (b, t1)
  
let (open_comp :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.comp ->
      (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.comp))
  =
  fun bs  ->
    fun t  ->
      let uu____4400 = open_binders' bs  in
      match uu____4400 with
      | (bs',opening) ->
          let uu____4411 = subst_comp opening t  in (bs', uu____4411)
  
let (open_pat :
  FStar_Syntax_Syntax.pat ->
    (FStar_Syntax_Syntax.pat * FStar_Syntax_Syntax.subst_t))
  =
  fun p  ->
    let rec open_pat_aux sub1 p1 =
      match p1.FStar_Syntax_Syntax.v with
      | FStar_Syntax_Syntax.Pat_constant uu____4461 -> (p1, sub1)
      | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
          let uu____4486 =
            FStar_All.pipe_right pats
              (FStar_List.fold_left
                 (fun uu____4557  ->
                    fun uu____4558  ->
                      match (uu____4557, uu____4558) with
                      | ((pats1,sub2),(p2,imp)) ->
                          let uu____4672 = open_pat_aux sub2 p2  in
                          (match uu____4672 with
                           | (p3,sub3) -> (((p3, imp) :: pats1), sub3)))
                 ([], sub1))
             in
          (match uu____4486 with
           | (pats1,sub2) ->
               ((let uu___638_4782 = p1  in
                 {
                   FStar_Syntax_Syntax.v =
                     (FStar_Syntax_Syntax.Pat_cons
                        (fv, (FStar_List.rev pats1)));
                   FStar_Syntax_Syntax.p =
                     (uu___638_4782.FStar_Syntax_Syntax.p)
                 }), sub2))
      | FStar_Syntax_Syntax.Pat_var x ->
          let x' =
            let uu___642_4803 = FStar_Syntax_Syntax.freshen_bv x  in
            let uu____4804 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___642_4803.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___642_4803.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____4804
            }  in
          let sub2 =
            let uu____4810 = shift_subst Prims.int_one sub1  in
            (FStar_Syntax_Syntax.DB (Prims.int_zero, x')) :: uu____4810  in
          ((let uu___646_4821 = p1  in
            {
              FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_var x');
              FStar_Syntax_Syntax.p = (uu___646_4821.FStar_Syntax_Syntax.p)
            }), sub2)
      | FStar_Syntax_Syntax.Pat_wild x ->
          let x' =
            let uu___650_4826 = FStar_Syntax_Syntax.freshen_bv x  in
            let uu____4827 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___650_4826.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___650_4826.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____4827
            }  in
          let sub2 =
            let uu____4833 = shift_subst Prims.int_one sub1  in
            (FStar_Syntax_Syntax.DB (Prims.int_zero, x')) :: uu____4833  in
          ((let uu___654_4844 = p1  in
            {
              FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_wild x');
              FStar_Syntax_Syntax.p = (uu___654_4844.FStar_Syntax_Syntax.p)
            }), sub2)
      | FStar_Syntax_Syntax.Pat_dot_term (x,t0) ->
          let x1 =
            let uu___660_4854 = x  in
            let uu____4855 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___660_4854.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___660_4854.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____4855
            }  in
          let t01 = subst sub1 t0  in
          ((let uu___664_4864 = p1  in
            {
              FStar_Syntax_Syntax.v =
                (FStar_Syntax_Syntax.Pat_dot_term (x1, t01));
              FStar_Syntax_Syntax.p = (uu___664_4864.FStar_Syntax_Syntax.p)
            }), sub1)
       in
    open_pat_aux [] p
  
let (open_branch' :
  FStar_Syntax_Syntax.branch ->
    (FStar_Syntax_Syntax.branch * FStar_Syntax_Syntax.subst_t))
  =
  fun uu____4878  ->
    match uu____4878 with
    | (p,wopt,e) ->
        let uu____4902 = open_pat p  in
        (match uu____4902 with
         | (p1,opening) ->
             let wopt1 =
               match wopt with
               | FStar_Pervasives_Native.None  ->
                   FStar_Pervasives_Native.None
               | FStar_Pervasives_Native.Some w ->
                   let uu____4931 = subst opening w  in
                   FStar_Pervasives_Native.Some uu____4931
                in
             let e1 = subst opening e  in ((p1, wopt1, e1), opening))
  
let (open_branch : FStar_Syntax_Syntax.branch -> FStar_Syntax_Syntax.branch)
  =
  fun br  ->
    let uu____4951 = open_branch' br  in
    match uu____4951 with | (br1,uu____4957) -> br1
  
let (close :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  =
  fun bs  ->
    fun t  -> let uu____4969 = closing_subst bs  in subst uu____4969 t
  
let (close_comp :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.comp)
  =
  fun bs  ->
    fun c  -> let uu____4983 = closing_subst bs  in subst_comp uu____4983 c
  
let (close_binders :
  FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.binders) =
  fun bs  ->
    let rec aux s bs1 =
      match bs1 with
      | [] -> []
      | (x,imp)::tl1 ->
          let x1 =
            let uu___696_5051 = x  in
            let uu____5052 = subst s x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___696_5051.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___696_5051.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____5052
            }  in
          let imp1 = subst_imp s imp  in
          let s' =
            let uu____5059 = shift_subst Prims.int_one s  in
            (FStar_Syntax_Syntax.NM (x1, Prims.int_zero)) :: uu____5059  in
          let uu____5065 = aux s' tl1  in (x1, imp1) :: uu____5065
       in
    aux [] bs
  
let (close_pat :
  FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t ->
    (FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t *
      FStar_Syntax_Syntax.subst_elt Prims.list))
  =
  fun p  ->
    let rec aux sub1 p1 =
      match p1.FStar_Syntax_Syntax.v with
      | FStar_Syntax_Syntax.Pat_constant uu____5129 -> (p1, sub1)
      | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
          let uu____5154 =
            FStar_All.pipe_right pats
              (FStar_List.fold_left
                 (fun uu____5225  ->
                    fun uu____5226  ->
                      match (uu____5225, uu____5226) with
                      | ((pats1,sub2),(p2,imp)) ->
                          let uu____5340 = aux sub2 p2  in
                          (match uu____5340 with
                           | (p3,sub3) -> (((p3, imp) :: pats1), sub3)))
                 ([], sub1))
             in
          (match uu____5154 with
           | (pats1,sub2) ->
               ((let uu___723_5450 = p1  in
                 {
                   FStar_Syntax_Syntax.v =
                     (FStar_Syntax_Syntax.Pat_cons
                        (fv, (FStar_List.rev pats1)));
                   FStar_Syntax_Syntax.p =
                     (uu___723_5450.FStar_Syntax_Syntax.p)
                 }), sub2))
      | FStar_Syntax_Syntax.Pat_var x ->
          let x1 =
            let uu___727_5471 = x  in
            let uu____5472 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___727_5471.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___727_5471.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____5472
            }  in
          let sub2 =
            let uu____5478 = shift_subst Prims.int_one sub1  in
            (FStar_Syntax_Syntax.NM (x1, Prims.int_zero)) :: uu____5478  in
          ((let uu___731_5489 = p1  in
            {
              FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_var x1);
              FStar_Syntax_Syntax.p = (uu___731_5489.FStar_Syntax_Syntax.p)
            }), sub2)
      | FStar_Syntax_Syntax.Pat_wild x ->
          let x1 =
            let uu___735_5494 = x  in
            let uu____5495 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___735_5494.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___735_5494.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____5495
            }  in
          let sub2 =
            let uu____5501 = shift_subst Prims.int_one sub1  in
            (FStar_Syntax_Syntax.NM (x1, Prims.int_zero)) :: uu____5501  in
          ((let uu___739_5512 = p1  in
            {
              FStar_Syntax_Syntax.v = (FStar_Syntax_Syntax.Pat_wild x1);
              FStar_Syntax_Syntax.p = (uu___739_5512.FStar_Syntax_Syntax.p)
            }), sub2)
      | FStar_Syntax_Syntax.Pat_dot_term (x,t0) ->
          let x1 =
            let uu___745_5522 = x  in
            let uu____5523 = subst sub1 x.FStar_Syntax_Syntax.sort  in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___745_5522.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___745_5522.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____5523
            }  in
          let t01 = subst sub1 t0  in
          ((let uu___749_5532 = p1  in
            {
              FStar_Syntax_Syntax.v =
                (FStar_Syntax_Syntax.Pat_dot_term (x1, t01));
              FStar_Syntax_Syntax.p = (uu___749_5532.FStar_Syntax_Syntax.p)
            }), sub1)
       in
    aux [] p
  
let (close_branch : FStar_Syntax_Syntax.branch -> FStar_Syntax_Syntax.branch)
  =
  fun uu____5542  ->
    match uu____5542 with
    | (p,wopt,e) ->
        let uu____5562 = close_pat p  in
        (match uu____5562 with
         | (p1,closing) ->
             let wopt1 =
               match wopt with
               | FStar_Pervasives_Native.None  ->
                   FStar_Pervasives_Native.None
               | FStar_Pervasives_Native.Some w ->
                   let uu____5599 = subst closing w  in
                   FStar_Pervasives_Native.Some uu____5599
                in
             let e1 = subst closing e  in (p1, wopt1, e1))
  
let (univ_var_opening :
  FStar_Syntax_Syntax.univ_names ->
    (FStar_Syntax_Syntax.subst_elt Prims.list * FStar_Syntax_Syntax.univ_name
      Prims.list))
  =
  fun us  ->
    let n1 = (FStar_List.length us) - Prims.int_one  in
    let s =
      FStar_All.pipe_right us
        (FStar_List.mapi
           (fun i  ->
              fun u  ->
                FStar_Syntax_Syntax.UN
                  ((n1 - i), (FStar_Syntax_Syntax.U_name u))))
       in
    (s, us)
  
let (univ_var_closing :
  FStar_Syntax_Syntax.univ_names -> FStar_Syntax_Syntax.subst_elt Prims.list)
  =
  fun us  ->
    let n1 = (FStar_List.length us) - Prims.int_one  in
    FStar_All.pipe_right us
      (FStar_List.mapi
         (fun i  -> fun u  -> FStar_Syntax_Syntax.UD (u, (n1 - i))))
  
let (open_univ_vars :
  FStar_Syntax_Syntax.univ_names ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.univ_names * FStar_Syntax_Syntax.term))
  =
  fun us  ->
    fun t  ->
      let uu____5687 = univ_var_opening us  in
      match uu____5687 with | (s,us') -> let t1 = subst s t  in (us', t1)
  
let (open_univ_vars_comp :
  FStar_Syntax_Syntax.univ_names ->
    FStar_Syntax_Syntax.comp ->
      (FStar_Syntax_Syntax.univ_names * FStar_Syntax_Syntax.comp))
  =
  fun us  ->
    fun c  ->
      let uu____5730 = univ_var_opening us  in
      match uu____5730 with
      | (s,us') -> let uu____5753 = subst_comp s c  in (us', uu____5753)
  
let (close_univ_vars :
  FStar_Syntax_Syntax.univ_names ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term)
  = fun us  -> fun t  -> let s = univ_var_closing us  in subst s t 
let (close_univ_vars_comp :
  FStar_Syntax_Syntax.univ_names ->
    FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.comp)
  =
  fun us  ->
    fun c  ->
      let n1 = (FStar_List.length us) - Prims.int_one  in
      let s =
        FStar_All.pipe_right us
          (FStar_List.mapi
             (fun i  -> fun u  -> FStar_Syntax_Syntax.UD (u, (n1 - i))))
         in
      subst_comp s c
  
let (open_let_rec :
  FStar_Syntax_Syntax.letbinding Prims.list ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.letbinding Prims.list * FStar_Syntax_Syntax.term))
  =
  fun lbs  ->
    fun t  ->
      let uu____5816 =
        let uu____5828 = FStar_Syntax_Syntax.is_top_level lbs  in
        if uu____5828
        then (Prims.int_zero, lbs, [])
        else
          FStar_List.fold_right
            (fun lb  ->
               fun uu____5868  ->
                 match uu____5868 with
                 | (i,lbs1,out) ->
                     let x =
                       let uu____5905 =
                         FStar_Util.left lb.FStar_Syntax_Syntax.lbname  in
                       FStar_Syntax_Syntax.freshen_bv uu____5905  in
                     ((i + Prims.int_one),
                       ((let uu___801_5913 = lb  in
                         {
                           FStar_Syntax_Syntax.lbname = (FStar_Util.Inl x);
                           FStar_Syntax_Syntax.lbunivs =
                             (uu___801_5913.FStar_Syntax_Syntax.lbunivs);
                           FStar_Syntax_Syntax.lbtyp =
                             (uu___801_5913.FStar_Syntax_Syntax.lbtyp);
                           FStar_Syntax_Syntax.lbeff =
                             (uu___801_5913.FStar_Syntax_Syntax.lbeff);
                           FStar_Syntax_Syntax.lbdef =
                             (uu___801_5913.FStar_Syntax_Syntax.lbdef);
                           FStar_Syntax_Syntax.lbattrs =
                             (uu___801_5913.FStar_Syntax_Syntax.lbattrs);
                           FStar_Syntax_Syntax.lbpos =
                             (uu___801_5913.FStar_Syntax_Syntax.lbpos)
                         }) :: lbs1), ((FStar_Syntax_Syntax.DB (i, x)) ::
                       out))) lbs (Prims.int_zero, [], [])
         in
      match uu____5816 with
      | (n_let_recs,lbs1,let_rec_opening) ->
          let lbs2 =
            FStar_All.pipe_right lbs1
              (FStar_List.map
                 (fun lb  ->
                    let uu____5956 =
                      FStar_List.fold_right
                        (fun u  ->
                           fun uu____5986  ->
                             match uu____5986 with
                             | (i,us,out) ->
                                 let u1 =
                                   FStar_Syntax_Syntax.new_univ_name
                                     FStar_Pervasives_Native.None
                                    in
                                 ((i + Prims.int_one), (u1 :: us),
                                   ((FStar_Syntax_Syntax.UN
                                       (i, (FStar_Syntax_Syntax.U_name u1)))
                                   :: out))) lb.FStar_Syntax_Syntax.lbunivs
                        (n_let_recs, [], let_rec_opening)
                       in
                    match uu____5956 with
                    | (uu____6035,us,u_let_rec_opening) ->
                        let uu___818_6048 = lb  in
                        let uu____6049 =
                          subst u_let_rec_opening
                            lb.FStar_Syntax_Syntax.lbtyp
                           in
                        let uu____6052 =
                          subst u_let_rec_opening
                            lb.FStar_Syntax_Syntax.lbdef
                           in
                        {
                          FStar_Syntax_Syntax.lbname =
                            (uu___818_6048.FStar_Syntax_Syntax.lbname);
                          FStar_Syntax_Syntax.lbunivs = us;
                          FStar_Syntax_Syntax.lbtyp = uu____6049;
                          FStar_Syntax_Syntax.lbeff =
                            (uu___818_6048.FStar_Syntax_Syntax.lbeff);
                          FStar_Syntax_Syntax.lbdef = uu____6052;
                          FStar_Syntax_Syntax.lbattrs =
                            (uu___818_6048.FStar_Syntax_Syntax.lbattrs);
                          FStar_Syntax_Syntax.lbpos =
                            (uu___818_6048.FStar_Syntax_Syntax.lbpos)
                        }))
             in
          let t1 = subst let_rec_opening t  in (lbs2, t1)
  
let (close_let_rec :
  FStar_Syntax_Syntax.letbinding Prims.list ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.letbinding Prims.list * FStar_Syntax_Syntax.term))
  =
  fun lbs  ->
    fun t  ->
      let uu____6079 =
        let uu____6087 = FStar_Syntax_Syntax.is_top_level lbs  in
        if uu____6087
        then (Prims.int_zero, [])
        else
          FStar_List.fold_right
            (fun lb  ->
               fun uu____6116  ->
                 match uu____6116 with
                 | (i,out) ->
                     let uu____6139 =
                       let uu____6142 =
                         let uu____6143 =
                           let uu____6149 =
                             FStar_Util.left lb.FStar_Syntax_Syntax.lbname
                              in
                           (uu____6149, i)  in
                         FStar_Syntax_Syntax.NM uu____6143  in
                       uu____6142 :: out  in
                     ((i + Prims.int_one), uu____6139)) lbs
            (Prims.int_zero, [])
         in
      match uu____6079 with
      | (n_let_recs,let_rec_closing) ->
          let lbs1 =
            FStar_All.pipe_right lbs
              (FStar_List.map
                 (fun lb  ->
                    let uu____6188 =
                      FStar_List.fold_right
                        (fun u  ->
                           fun uu____6208  ->
                             match uu____6208 with
                             | (i,out) ->
                                 ((i + Prims.int_one),
                                   ((FStar_Syntax_Syntax.UD (u, i)) :: out)))
                        lb.FStar_Syntax_Syntax.lbunivs
                        (n_let_recs, let_rec_closing)
                       in
                    match uu____6188 with
                    | (uu____6239,u_let_rec_closing) ->
                        let uu___840_6247 = lb  in
                        let uu____6248 =
                          subst u_let_rec_closing
                            lb.FStar_Syntax_Syntax.lbtyp
                           in
                        let uu____6251 =
                          subst u_let_rec_closing
                            lb.FStar_Syntax_Syntax.lbdef
                           in
                        {
                          FStar_Syntax_Syntax.lbname =
                            (uu___840_6247.FStar_Syntax_Syntax.lbname);
                          FStar_Syntax_Syntax.lbunivs =
                            (uu___840_6247.FStar_Syntax_Syntax.lbunivs);
                          FStar_Syntax_Syntax.lbtyp = uu____6248;
                          FStar_Syntax_Syntax.lbeff =
                            (uu___840_6247.FStar_Syntax_Syntax.lbeff);
                          FStar_Syntax_Syntax.lbdef = uu____6251;
                          FStar_Syntax_Syntax.lbattrs =
                            (uu___840_6247.FStar_Syntax_Syntax.lbattrs);
                          FStar_Syntax_Syntax.lbpos =
                            (uu___840_6247.FStar_Syntax_Syntax.lbpos)
                        }))
             in
          let t1 = subst let_rec_closing t  in (lbs1, t1)
  
let (close_tscheme :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.tscheme -> FStar_Syntax_Syntax.tscheme)
  =
  fun binders  ->
    fun uu____6267  ->
      match uu____6267 with
      | (us,t) ->
          let n1 = (FStar_List.length binders) - Prims.int_one  in
          let k = FStar_List.length us  in
          let s =
            FStar_List.mapi
              (fun i  ->
                 fun uu____6302  ->
                   match uu____6302 with
                   | (x,uu____6311) ->
                       FStar_Syntax_Syntax.NM (x, (k + (n1 - i)))) binders
             in
          let t1 = subst s t  in (us, t1)
  
let (close_univ_vars_tscheme :
  FStar_Syntax_Syntax.univ_names ->
    FStar_Syntax_Syntax.tscheme -> FStar_Syntax_Syntax.tscheme)
  =
  fun us  ->
    fun uu____6332  ->
      match uu____6332 with
      | (us',t) ->
          let n1 = (FStar_List.length us) - Prims.int_one  in
          let k = FStar_List.length us'  in
          let s =
            FStar_List.mapi
              (fun i  -> fun x  -> FStar_Syntax_Syntax.UD (x, (k + (n1 - i))))
              us
             in
          let uu____6356 = subst s t  in (us', uu____6356)
  
let (subst_tscheme :
  FStar_Syntax_Syntax.subst_elt Prims.list ->
    FStar_Syntax_Syntax.tscheme -> FStar_Syntax_Syntax.tscheme)
  =
  fun s  ->
    fun uu____6375  ->
      match uu____6375 with
      | (us,t) ->
          let s1 = shift_subst (FStar_List.length us) s  in
          let uu____6389 = subst s1 t  in (us, uu____6389)
  
let (opening_of_binders :
  FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.subst_t) =
  fun bs  ->
    let n1 = (FStar_List.length bs) - Prims.int_one  in
    FStar_All.pipe_right bs
      (FStar_List.mapi
         (fun i  ->
            fun uu____6430  ->
              match uu____6430 with
              | (x,uu____6439) -> FStar_Syntax_Syntax.DB ((n1 - i), x)))
  
let (closing_of_binders :
  FStar_Syntax_Syntax.binders -> FStar_Syntax_Syntax.subst_t) =
  fun bs  -> closing_subst bs 
let (open_term_1 :
  FStar_Syntax_Syntax.binder ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.binder * FStar_Syntax_Syntax.term))
  =
  fun b  ->
    fun t  ->
      let uu____6466 = open_term [b] t  in
      match uu____6466 with
      | (b1::[],t1) -> (b1, t1)
      | uu____6507 -> failwith "impossible: open_term_1"
  
let (open_term_bvs :
  FStar_Syntax_Syntax.bv Prims.list ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.bv Prims.list * FStar_Syntax_Syntax.term))
  =
  fun bvs  ->
    fun t  ->
      let uu____6538 =
        let uu____6543 = FStar_List.map FStar_Syntax_Syntax.mk_binder bvs  in
        open_term uu____6543 t  in
      match uu____6538 with
      | (bs,t1) ->
          let uu____6558 = FStar_List.map FStar_Pervasives_Native.fst bs  in
          (uu____6558, t1)
  
let (open_term_bv :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.term ->
      (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term))
  =
  fun bv  ->
    fun t  ->
      let uu____6586 = open_term_bvs [bv] t  in
      match uu____6586 with
      | (bv1::[],t1) -> (bv1, t1)
      | uu____6601 -> failwith "impossible: open_term_bv"
  