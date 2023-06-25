CHECK_NAME_FILE = check_name.txt
TEXT = check_yomi_all.txt
NOGEOCODE = nogeocode.txt
LIBARRYCATEGORY = library_category.txt
MUSEUMCATEGORY  = museum_category.txt
TODAY = `date +%Y%m%d`

all: library_category museum_category geocode check_yomi_all

library_category:
	echo "適切なサブカテゴリを持たない図書館施設一覧です。" > $(LIBARRYCATEGORY)
	./library_category.py -cat:図書館 >> $(LIBARRYCATEGORY)
	./put.py -page:利用者:Masao/LibraryCategory -file:$(LIBARRYCATEGORY) -summary:サブカテゴリを持たない図書館施設一覧を更新

museum_category:
	echo "適切なサブカテゴリを持たない博物館施設一覧です。" > $(MUSEUMCATEGORY)
	./museum_category.py -cat:博物館 -ns:0 >> $(MUSEUMCATEGORY)
	./put.py -page:saveMLAK:博物館サブカテゴリの追加/修正一覧 -file:$(MUSEUMCATEGORY) -summary:サブカテゴリを持たない博物館施設一覧を更新

geocode:
	echo "自動で「緯度経度」項目が入手できなかった施設一覧です:" > $(NOGEOCODE)
	./geocode.py -ns:0 -category:施設緯度経度未付与 -always >> $(NOGEOCODE)
	./put.py -page:利用者:Masao/NoGeocode -file:$(NOGEOCODE) -summary:「緯度経度」自動取得による更新を反映


check_name:
	./check_name.py -cat:施設 -ns:0 > $(CHECK_NAME_FILE)
	./put.py -page:利用者:Masao/Name_Check -file:$(CHECK_NAME_FILE) -summary:名称不一致の項目一覧を更新

check_yomi:
	./check_yomi.py -always -cat:施設 -ns:0

check_yomi_all:
	-rm -f $(TEXT)
	echo -e "「よみ」項目が付与されていない記事です：" > $(TEXT)
	echo "== [[:Category:北海道|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:北海道 >> $(TEXT)
	echo "== [[:Category:青森県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:青森県 >> $(TEXT)
	echo "== [[:Category:岩手県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:岩手県 >> $(TEXT)
	echo "== [[:Category:宮城県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:宮城県 >> $(TEXT)
	echo "== [[:Category:秋田県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:秋田県 >> $(TEXT)
	echo "== [[:Category:山形県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:山形県 >> $(TEXT)
	echo "== [[:Category:福島県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:福島県 >> $(TEXT)
	echo "== [[:Category:茨城県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:茨城県 >> $(TEXT)
	echo "== [[:Category:栃木県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:栃木県 >> $(TEXT)
	echo "== [[:Category:群馬県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:群馬県 >> $(TEXT)
	echo "== [[:Category:埼玉県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:埼玉県 >> $(TEXT)
	echo "== [[:Category:千葉県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:千葉県 >> $(TEXT)
	echo "== [[:Category:東京都|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:東京都 >> $(TEXT)
	echo "== [[:Category:神奈川県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:神奈川県 >> $(TEXT)
	echo "== [[:Category:新潟県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:新潟県 >> $(TEXT)
	echo "== [[:Category:山梨県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:山梨県 >> $(TEXT)
	echo "== [[:Category:長野県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:長野県 >> $(TEXT)
	echo "== [[:Category:京都府|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:京都府 >> $(TEXT)
	echo "== [[:Category:福岡県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:福岡県 >> $(TEXT)
	echo "== [[:Category:熊本県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:熊本県 >> $(TEXT)
	echo "== [[:Category:大分県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -ns:0 -cat:大分県 >> $(TEXT)
	./put.py -page:利用者:Masao/Yomi_Check -file:$(TEXT) -summary:「よみ」未付与の項目一覧を更新

check_jdarchive:
	./external-url-filter.rb savemlak-el-all.txt | ./external-url-diff.rb savemlak-el-20*.txt | ./external-url-style.rb -base:$(TODAY)
	for f in $(TODAY)-*; do \
	  ./createpage.py -page:saveMLAK:jdarchive/seeds/$$f -file:$$f "-summary:jdarchive seeds list at $(TODAY)"; \
	done;
	ruby -e 'puts ARGV.sort_by{|e| e.split(/-/).map{|e2| e2.to_i} }.map{|f| "*{{jdarchive-list|#{ f }}}" }' $(TODAY)-* > jdarchive-list
	cd ../pywikipedia; python add_text.py -noreorder -page:saveMLAK:jdarchive/seeds -textfile:../savemlak/jdarchive-list -always

.PHONY: check_name check_yomi check_yomi_all geocode library_category
