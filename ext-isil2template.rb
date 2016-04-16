#!/usr/bin/env ruby

require "nkf"

default_category = "公共図書館"
if ARGV[0] == "-default"
  ARGV.shift
  default_category = ARGV.shift
end

ARGF.each do |line|
  line = NKF.nkf("-SwZ1", line)
  isil, name, name_en, yomi, postal_code, pref, city, address, tel, fax, 	url, = line.chomp.split( /\t/ )
  next if not isil =~ /\AJP-/ # skip non ISIL data line.
  next if name.nil? or name.empty?
  yomi = yomi.tr('ァ-ン', 'ぁ-ん')
  title = name.dup
  title.gsub!(/\A(独立行政法人|公益財団法人)/, "")
  if title != name
    puts "#{name} ::=> #{title}"
  end
  city_cat = city
  if city_cat =~ /区\Z/
    city_cat.sub!(/市.*\Z/, "市")
  elsif city_cat =~ /.+郡(.+)\Z/
    print city_cat
    city_cat = $1.dup
    puts "-> #{city_cat}"
  end
  category = default_category.dup
  if name =~ /大学/
    category = "大学図書館"
  end
  open("#{name}.txt", "w") do |io|
    io.print <<EOF
{{施設
|名称=#{name}
|よみ=#{yomi}
|所在地=〒#{postal_code} #{pref}#{city}#{address}
|電話番号=#{tel}
|FAX=#{fax}
|緯度経度=
|URL=#{url}
}}
== 被害状況 ==
=== 職員・利用者の被害 ===


=== 施設の被害 ===


=== 蔵書・収蔵品・展示の被害 ===


=== その他の被害 ===


== 運営情報 ==


== 救援状況 ==

== 避難受入情報 ==

=== 避難受入規模 ===

== その他 ==
<!--自由記述：求める／求められている救援情報を詳しく記入しましょう-->


== 情報源 ==
<!--ここにはなにもいれません、「情報源」は見出しです。-->
=== 記入者 ===
<!--Twitterアカウント等でも結構です-->
*
=== 元情報 ===
<!--自分の目で確認・MLへの関係者の投稿から等-->
*

[[Category:#{pref}]]
[[Category:#{pref}/#{city_cat}]]
[[Category:図書館]]
[[Category:#{category}]]
EOF
  end
end
