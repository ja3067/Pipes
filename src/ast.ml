
(* The Abstract Syntax Tree (AST) for the Coral Programming Language *)

(* This AST supports many of the features of modern Python, with the exception of 
exceptions, and some built-in data-structures supported by Python. See the SAST
for more detailed explanations of these types.

ListAccess is included as a binary operation for simplicity during code generation. 
Import and Type statements are handled in semant and do not make it to the code 
generation stage *)

type operator = Add | Sub | Mul | Div | Exp | Eq | Neq | Less | Leq | Greater | Geq | And | Or | ListAccess

type uop = Neg | Not

type literal =
  | IntLit of int
  | BoolLit of bool
  | FloatLit of float
  | StringLit of string

type typ = Int | Float | Bool | String | Dyn | Arr | Object | FuncType | Null

type bind = Bind of string * typ

type expr =
  | Binop of expr * operator * expr
  | Lit of literal
  | Var of bind
  | Unop of uop * expr
  | Call of expr * expr list
  | Method of expr * string * expr list
  | Field of expr * string
  | List of expr list
  | ListAccess of expr * expr (* expr, entry *)
  | ListSlice of expr * expr * expr (* expr, left, right *)
  | Cast of typ * expr (* type casting *)
  | Lambda of bind list * expr
  | Noexpr

type stmt =
  | Func of bind option * bind list * expr list * stmt (* name * formals list * partials list * body *)
  | Block of stmt list
  | Expr of expr
  | If of expr * stmt * stmt
  | For of bind * expr * stmt
  | Range of bind * expr * stmt
  | While of expr * stmt
  | Return of expr
  | Class of string * stmt
  | Asn of expr list * expr
  | Type of expr
  | Print of expr
  | Import of string
  | Continue
  | Break
  | Nop
  | Pass


let rec string_of_op = function
  | Add -> "+"
  | Sub -> "-"
  | Mul -> "*"
  | Div -> "/"
  | Exp -> "**"
  | Eq -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "and"
  | Or -> "or"
  | ListAccess -> "at index"

let rec string_of_uop = function
  | Neg -> "-"
  | Not -> "not"

let rec string_of_lit = function
  | IntLit(i) -> string_of_int i
  | BoolLit(b) -> string_of_bool b
  | FloatLit(f) -> string_of_float f
  | StringLit(s) -> "\"" ^ s ^ "\""

let rec string_of_typ = function
  | Int -> "int"
  | Float -> "float"
  | Bool -> "bool"
  | String -> "str"
  | Dyn -> "dyn"
  | Arr -> "list"
  | FuncType -> "func"
  | Object -> "object"
  | Null -> "null"

let rec string_of_bind = function
  | Bind(s, t) -> s

let rec string_of_expr = function
  | Binop(e1, o, e2) -> string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Lit(l) -> string_of_lit l
  | Var(b) -> string_of_bind b
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Call(e, el) -> string_of_expr e ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Method(obj, m, el) -> string_of_expr obj ^ "." ^ m ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Field(obj, s) -> string_of_expr obj ^ "." ^ s
  | List(el) -> String.concat ", " (List.map string_of_expr el)
  | ListAccess(e1, e2) -> string_of_expr e1 ^ "[" ^ string_of_expr e2 ^ "]"
  | ListSlice(e1, e2, e3) -> string_of_expr e1 ^ "[" ^ string_of_expr e2 ^ ":" ^ string_of_expr e3 ^ "]"
  | Cast(a, b) -> string_of_typ a ^ "(" ^ string_of_expr b ^ ")"
  | Lambda(a, b) -> "lambda " ^ String.concat " " (List.map (fun (Bind(x, _)) -> x) a) ^ " : " ^ string_of_expr b
  
let rec string_of_stmt indent = function
  | Func(b, bl, pl, s) -> (String.make indent '\t') ^ "def " ^ (match b with | Some x -> string_of_bind x | None -> "") ^ "(" ^ String.concat ", " (List.map string_of_bind bl) ^ "):\n" ^ string_of_stmt (indent + 1) s
  | Block(sl) -> String.concat "\n" (List.map (string_of_stmt indent) sl) ^ "\n"
  | Expr(e) -> (String.make indent '\t') ^ string_of_expr e
  | If(e, s1, s2) ->  (String.make indent '\t') ^ "if " ^ string_of_expr e ^ ":\n" ^ string_of_stmt (indent + 1) s1 ^ "else:\n" ^ string_of_stmt (indent + 1) s2
  | For(b, e, s) -> (String.make indent '\t') ^ "for " ^ string_of_bind b ^ " in " ^ string_of_expr e ^ ":\n" ^ string_of_stmt (indent + 1) s
  | Range(b, e, s) -> (String.make indent '\t') ^ "for " ^ string_of_bind b ^ " in range (" ^ string_of_expr e ^ "):\n" ^ string_of_stmt (indent + 1) s
  | While(e, s) -> (String.make indent '\t') ^ "while " ^ string_of_expr e ^ ":\n" ^ string_of_stmt (indent + 1) s
  | Return(e) -> (String.make indent '\t') ^ "return " ^ string_of_expr e ^ "\n"
  | Class(str, s) -> (String.make indent '\t') ^ "class " ^ str ^ ":\n" ^ string_of_stmt (indent + 1) s
  | Asn(el, e) -> (String.make indent '\t') ^ String.concat ", " (List.map string_of_expr el) ^ " = "  ^ string_of_expr e
  | Type(e) -> (String.make indent '\t') ^ string_of_expr e
  | Print(e) -> (String.make indent '\t') ^ string_of_expr e
  | Import(e) -> (String.make indent '\t') ^ "import " ^ e
  | Nop -> ""
  | Continue -> (String.make indent '\t') ^ "continue"
  | Break -> (String.make indent '\t') ^ "break"
  | Pass -> "pass"

and string_of_program l = String.concat "\n" (List.map (string_of_stmt 0) l) ^ "\n\n"

