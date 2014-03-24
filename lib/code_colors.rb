class CodeColors < Rouge::CSSTheme
  name 'codecolors'

  palette common: "#ffffff"
  palette string: "#ccff66"
  palette symbol: "#ff6666"
  palette punct:  "#ffffff"
  palette keyword:"#9966ff"
  palette attribute:"#66ccff"

  palette base00: "#151515"
  palette base02: "#ffffff"
  palette base03: "#505050"
  palette base04: "#b0b0b0"
  palette base06: "#e0e0e0"
  palette base08: "#ac4142"
  palette base0A: "#f4bf75"
  palette base0C: "#75b5aa"
  palette base0D: "#6a9fb5"
  palette base0F: "#8f5536"
  

  style Text, :fg => :base02

  style Error, :fg => :base00, :bg => :base08
  style Comment, :fg => :base03

  style Comment::Preproc,
        Name::Tag, :fg => :base0A

  style Operator,
        Punctuation, :fg => :punct

  style Generic::Inserted, :fg => :string
  style Generic::Deleted, :fg => :base08
  style Generic::Heading, :fg => :attribute, :bg => :base00, :bold => true

  style Keyword, :fg => :keyword
  style Keyword::Constant,
        Keyword::Type, :fg => :symbol

  style Keyword::Declaration, :fg => :symbol

  style Literal::String, :fg => :string
  style Literal::String::Regex, :fg => :base0C

  style Literal::String::Interpol,
        Literal::String::Escape, :fg => :base0F

  style Name::Namespace,
        Name::Class,
        Name::Constant, :fg => :base0A

  style Name::Attribute, :fg => :attribute

  style Literal::Number,
        Literal::String::Symbol, :fg => :string
end