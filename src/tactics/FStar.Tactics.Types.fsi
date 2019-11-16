#light "off"
module FStar.Tactics.Types

open FStar.All
open FStar.Syntax.Syntax
open FStar.TypeChecker.Env
module Cfg = FStar.TypeChecker.Cfg
module N = FStar.TypeChecker.Normalize
module Range = FStar.Range
module BU = FStar.Util

(*
   f: x:int -> P
   ==================
      P
 *)
//A goal is typically of the form
//    G |- ?u : t
// where context = G
//       witness = ?u, although, more generally, witness is a partial solution and can be any term
//       goal_ty = t
type goal = {
    goal_main_env: env;
    goal_ctx_uvar : ctx_uvar;
    opts    : FStar.Options.optionstate; // option state for this particular goal
    is_guard : bool; // Marks whether this goal arised from a guard during tactic runtime
                     // We make the distinction to be more user-friendly at times
    label : string; // A user-defined description
}
type guard_policy =
    | Goal
    | SMT
    | Force
    | Drop // unsound

type proofstate = {
    main_context : env;          //the shared top-level context for all goals
    all_implicits: implicits ;   //all the implicits currently open, partially resolved

    // NOTE: Goals are user-settable, the "goals" we mean in
    // the paper are the implicits above, these are simply a
    // way for primitives to take/give goals, and a way
    // to have the SMT goal set. What we should really do
    // is go full-LCF and take them as arguments, returning them
    // as values. This goal stack should be user-level.
    goals        : list<goal>;   //all the goals remaining to be solved
    smt_goals    : list<goal>;   //goals that have been deferred to SMT

    depth        : int;          //depth for tracing and debugging
    __dump       : proofstate -> string -> unit; // callback to dump_proofstate, to avoid an annoying circularity
    psc          : Cfg.psc;        //primitive step context where we started execution
    entry_range  : Range.range;  //position of entry, set by the use
    guard_policy : guard_policy; //guard policy: what to do with guards arising during tactic exec
    freshness    : int;          //a simple freshness counter for the fresh tactic
    tac_verb_dbg : bool;         //whether to print verbose debugging messages

    local_state  : BU.psmap<term>; // local metaprogram state
}

val decr_depth : proofstate -> proofstate
val incr_depth : proofstate -> proofstate
val tracepoint : Cfg.psc -> proofstate -> unit
val set_proofstate_range : proofstate -> Range.range -> proofstate

val subst_proof_state: subst_t -> proofstate -> proofstate

val set_ps_psc : Cfg.psc -> proofstate -> proofstate
val goal_env: goal -> env
val goal_witness: goal -> term
val goal_type: goal -> term
val goal_with_type: goal -> term -> goal
val goal_with_env: goal -> env -> goal
val is_guard : goal -> bool

val get_label : goal -> string
val set_label : string -> goal -> goal

val goals_of     : proofstate -> list<goal>
val smt_goals_of : proofstate -> list<goal>

val mk_goal: env -> ctx_uvar -> FStar.Options.optionstate -> bool -> string -> goal
type direction =
    | TopDown
    | BottomUp

exception TacticFailure of string
exception EExn of term
