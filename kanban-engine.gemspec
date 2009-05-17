PKG_FILES = [ "lib/card.rb" ]

Gem::Specification.new do |s|
  s.name = 'kanban-engine'
  s.version = "0.1.1"
  s.summary = 'Library to support modeling kanban'
  s.description = <<-EOF
Kanban is a system developed initially by Toyota for tracking work in progress 
in lean and agile teams. For a good overview see http://www.agileproductdesign.com/blog/2009/kanban_over_simplified.html.
EOF
  s.files = PKG_FILES
  s.require_path = 'lib'
  s.has_rdoc = false
  
  s.author = 'Marcus Irven'
  s.email = 'marcus@marcusirven.com'
  s.homepage = 'http://github.com/mirven/kanban-engine'
end
