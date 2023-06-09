const std = @import("std");
const token = @import("token.zig");
const helper = @import("../helper/helper.zig");

pub const Lexer = struct {
  const Self = @This();
  input: []const u8,
  cursor: usize = 0,
  read_cursor: usize = 0,
  ch: u8 = 0,

  pub fn print_lexer(l: *Self) void{
    std.debug.print("input: {s}, position: {}, read_position: {}, ch: {c}", 
    .{l.input, l.cursor, l.read_cursor, l.ch});
  }

   pub fn read_char(self: *Self) void {
        if (self.read_cursor >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_cursor];
        }
        self.cursor = self.read_cursor;
        self.read_cursor += 1;
    }

    fn peek_char(self: *Self) u8 {
      if(self.read_cursor >= self.input.len){
        return '0';
      }
      return self.input[self.cursor+1];
    }

  pub fn next_token(l: *Self) token.Token {
    l.skip_whitespace();
    var tok = token.Token{
      .ttype = token.TokenType.Illegal,
      .literal = l.current_string()
    };
    switch (l.ch) {
      '=' => {
        if(l.peek_char() == '='){
          tok.literal = l.input[l.cursor..l.read_cursor+1];
          tok.ttype = token.TokenType.EqEq;
          l.read_cursor+=1;
        }
        else {
          tok.ttype = token.TokenType.Assign;
        }
        },

      ';' => tok.ttype = token.TokenType.SemiColon,
      ',' => tok.ttype = token.TokenType.Comma,
      '(' => tok.ttype = token.TokenType.Lapren,
      ')' => tok.ttype = token.TokenType.Rparen,
      '{' => tok.ttype = token.TokenType.Lbrace,
      '}' => tok.ttype = token.TokenType.Rbrace,
      '+' => tok.ttype = token.TokenType.Plus,
      '!' => {
        if(l.peek_char() == '='){
          tok.literal = l.input[l.cursor..l.read_cursor+1];
          tok.ttype = token.TokenType.BangEqual;
          l.read_cursor+=1;
        }
        else{
          tok.ttype = token.TokenType.Bang;
        }
        },
      '/' => tok.ttype = token.TokenType.Slash,
      '-' => tok.ttype = token.TokenType.Minus,
      '*' => tok.ttype = token.TokenType.Star,
      '>' => tok.ttype = token.TokenType.Gt,
      '<' => tok.ttype = token.TokenType.Lt,
       0  => tok.ttype = token.TokenType.Eof,
      '0'...'9' => {
        const ident = l.read_number();
        tok.ttype = token.TokenType.Int;
        tok.literal = ident;
        l.read_cursor-=1;
      },
      'a'...'z', 'A'...'Z', '_' => {
        tok.ttype = look_up_ident(l.read_indetifier());
        tok.literal = l.read_indetifier();
        l.read_cursor-=1;
      },
      '"' => {
        if(is_letter(l.peek_char())){
          tok.ttype = token.TokenType.String;
          tok.literal = l.read_string();
        }else{
          tok.ttype = token.TokenType.Illegal;
        }
      },
       else => tok.ttype = token.TokenType.Illegal, 
    }
    l.read_char();
    return tok;
  }

  fn read_indetifier(self: *Self) []const u8{
    var position = self.cursor;
    while(is_letter(self.ch)){
      self.read_char();
    }
    return self.input[position..self.cursor];
  }

  fn read_number(self: *Self) []const u8{
    var pos = self.cursor;
    while(is_digit(self.ch)){
      self.read_char();
    }
    return self.input[pos..self.cursor];
  }

  fn read_string(self: *Self) []const u8{
    self.read_char();
    var pos = self.cursor;
    while(is_letter(self.ch)){
      self.read_char();
    }
    return self.input[pos..self.cursor];
  }

  fn current_string(self: Self) []const u8 {
    if(self.cursor < self.input.len){
      return self.input[self.cursor..self.cursor+1];
    }
    else {
      return "0";
    }
  }

  fn skip_whitespace(self: *Self) void {
    while(self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r'){
      self.read_char();
    }
  }
  
  pub fn has_tokens(self: *Self) bool {
    return self.read_cursor <= self.input.len;
  }

};

pub fn init(input: []const u8) Lexer {
  var nl = Lexer{
    .input = input
  };
  nl.read_char();
  return nl;
}

fn is_letter(ch: u8) bool {
  return 'a' <= ch and ch <= 'z' or 'A' <= ch and ch <= 'Z' or ch == '_';
}

fn is_digit(ch: u8) bool {
  return '0' <= ch and ch <= '9';
}

fn look_up_ident(ident: []const u8) token.TokenType{
  if(helper.compare_string(ident, "let")){
    return token.TokenType.Let;
  }
  else if(helper.compare_string(ident, "fn")){
    return token.TokenType.Function;
  }
  else if(helper.compare_string(ident, "false")){
    return token.TokenType.False;
  }
  else if(helper.compare_string(ident, "true")){
    return token.TokenType.True;
  }
  else if(helper.compare_string(ident, "if")){
    return token.TokenType.If;
  }
  else if(helper.compare_string(ident, "else")){
    return token.TokenType.Else;
  }
  else if(helper.compare_string(ident, "return")){
    return token.TokenType.Return;
  }
  else{
    return token.TokenType.Ident;
  }
}