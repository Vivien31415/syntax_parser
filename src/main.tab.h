/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_SRC_MAIN_TAB_H_INCLUDED
# define YY_YY_SRC_MAIN_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_INT = 258,
    T_VOID = 259,
    T_BOOL = 260,
    T_CHAR = 261,
    T_STRING = 262,
    IF = 263,
    WHILE = 264,
    FOR = 265,
    PRINTF = 266,
    SCANF = 267,
    RETURN = 268,
    SEMICOLON = 269,
    COMMA = 270,
    LPAREN = 271,
    RPAREN = 272,
    LBRACE = 273,
    RBRACE = 274,
    LBRACKET = 275,
    RBRACKET = 276,
    LOWER_THEN_ELSE = 277,
    ELSE = 278,
    CHAR = 279,
    INT = 280,
    STRING = 281,
    BOOL = 282,
    ID = 283,
    ASSIGN = 284,
    ADD_ASSI = 285,
    SUB_ASSI = 286,
    MUL_ASSI = 287,
    DIV_ASSI = 288,
    MOD_ASSI = 289,
    OR = 290,
    AND = 291,
    EQ = 292,
    NE = 293,
    GT = 294,
    LT = 295,
    GE = 296,
    LE = 297,
    ADD = 298,
    SUB = 299,
    MUL = 300,
    DIV = 301,
    MOD = 302,
    NOT = 303,
    INC = 304,
    DEC = 305,
    UPLUS = 306,
    UMINUS = 307,
    ADDR = 308,
    POST_INC = 309,
    POST_DEC = 310
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_SRC_MAIN_TAB_H_INCLUDED  */
