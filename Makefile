TEXT = check_yomi_all.txt
NOGEOCODE = nogeocode.txt
LIBARRYCATEGORY = library_category.txt
MUSEUMCATEGORY  = museum_category.txt

all: library_category museum_category geocode check_yomi_all

library_category:
	echo "適切なサブカテゴリを持たない図書館施設一覧です。" > $(LIBARRYCATEGORY)
	./library_category.py -cat:図書館 >> $(LIBARRYCATEGORY)
	./put.py -page:利用者:Masao/LibraryCategory -file:$(LIBARRYCATEGORY) -summary:サブカテゴリを持たない図書館施設一覧を更新

museum_category:
	echo "適切なサブカテゴリを持たない博物館施設一覧です。" > $(MUSEUMCATEGORY)
	./museum_category.py -cat:博物館 >> $(MUSEUMCATEGORY)
	./put.py -page:saveMLAK:博物館サブカテゴリの追加/修正一覧 -file:$(MUSEUMCATEGORY) -summary:サブカテゴリを持たない博物館施設一覧を更新

geocode:
	echo "自動で「緯度経度」項目が入手できなかった施設一覧です:" > $(NOGEOCODE)
	./geocode.py -ns:0 -transcludes:施設 -always >> $(NOGEOCODE)
	./put.py -page:利用者:Masao/NoGeocode -file:$(NOGEOCODE) -summary:「緯度経度」自動取得による更新を反映


check_yomi:
	./check_yomi.py -always -cat:文書館 -cat:博物館 -cat:図書館

check_yomi_all:
	-rm -f $(TEXT)
	echo -e "「よみ」項目が付与されていない記事です：" > $(TEXT)
	echo "== [[:Category:北海道|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:北海道 >> $(TEXT)
	echo "== [[:Category:青森県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:青森県 >> $(TEXT)
	echo "== [[:Category:岩手県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:岩手県 >> $(TEXT)
	echo "== [[:Category:宮城県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:宮城県 >> $(TEXT)
	echo "== [[:Category:秋田県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:秋田県 >> $(TEXT)
	echo "== [[:Category:山形県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:山形県 >> $(TEXT)
	echo "== [[:Category:福島県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:福島県 >> $(TEXT)
	echo "== [[:Category:茨城県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:茨城県 >> $(TEXT)
	echo "== [[:Category:栃木県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:栃木県 >> $(TEXT)
	echo "== [[:Category:群馬県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:群馬県 >> $(TEXT)
	echo "== [[:Category:埼玉県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:埼玉県 >> $(TEXT)
	echo "== [[:Category:千葉県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:千葉県 >> $(TEXT)
	echo "== [[:Category:東京都|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:東京都 >> $(TEXT)
	echo "== [[:Category:神奈川県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:神奈川県 >> $(TEXT)
	echo "== [[:Category:新潟県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:新潟県 >> $(TEXT)
	echo "== [[:Category:山梨県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:山梨県 >> $(TEXT)
	echo "== [[:Category:長野県|]] ==" >> $(TEXT)
	./check_yomi.py -outputwiki -cat:長野県 >> $(TEXT)
	./put.py -page:利用者:Masao/Yomi_Check -file:$(TEXT) -summary:「よみ」未付与の項目一覧を更新


.PHONY: check_yomi check_yomi_all geocode library_category
