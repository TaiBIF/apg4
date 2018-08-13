CREATE OR REPLACE FUNCTION public.simplyname(
	fullname text)
    RETURNS text
    LANGUAGE 'plpython3u'

    COST 100
    VOLATILE 
AS $BODY$

import re
### processing subordinate
global fullname
fullname = re.sub('  ',' ', fullname)
fullname_split = fullname.split(' ')
length_fullname = len(fullname_split)

epithetLst = []
epithet = ''
author_start = ''
cross_type = ''
subordinate_status = []

subrank = ['subsp.', 'ssp.', 'var.', 'fo.', 'cv.', '×', 'x']
autonym = 'false'
for s in range(0,len(subrank)):
    if subrank[s] in fullname_split:
        subrank_idx = fullname_split.index(subrank[s])
        if subrank[s] == '×' or subrank[s] == 'x':
            # 把 x 取代成 ×
            subrank[s] = '×'
            fullname_split[subrank_idx] = '×'
            # × 後面有跟著屬名的
            # ex: Genus epithet × Genus epithet2
            if re.search('[A-Z].*', fullname_split[subrank_idx+1]):
                subordinate_status.append([subrank_idx, subrank[s]])
                cross_type = 1
            else:
                # 沒有屬名的 case
                fullname_split[subrank_idx+1] = '×' + fullname_split[subrank_idx+1]
                fullname_split.remove(subrank[s])
        else:
            subordinate_status.append([subrank_idx, subrank[s]])

        # check for autonyms
        epithet = fullname_split[1]
        sub_epithet = fullname_split[subrank_idx + 1]
        if epithet == sub_epithet:
            autonym = True

fname_sp = ' '.join(str(item) for item in fullname_split[0:2])

#### 有種下階層的
subordinate_status = sorted(subordinate_status)

if cross_type == 1:
    sidx = int(subordinate_status[0][0])
    subepithet = fullname_split[sidx+1] + ' ' + fullname_split[sidx+2]
    speciesAuthors = ' '.join(str(item) for item in fullname_split[2:sidx])
    subepithetAuthors = ' '.join(str(item) for item in fullname_split[sidx+3:len(fullname_split)])
    fullnameNoAuthors = ' '.join([fname_sp, '×',subepithet])

# autonym
elif autonym == True:
    subrank_name = fullname_split[subrank_idx]
    subepithet = fullname_split[subordinate_status[0][0]+1]
    fullnameNoAuthors = ' '.join([fname_sp, subrank_name, subepithet])

# 只有一個種下階層的
elif len(subordinate_status) == 1:
    subrank_name = fullname_split[subrank_idx]
    subepithet = fullname_split[subordinate_status[0][0]+1]

    fullnameNoAuthors = ' '.join([fname_sp, subrank_name, subepithet])

elif len(subordinate_status) > 1:
    subrank_idx = []
    subrank_name = []
    subepithet = []
    for srn in range(0,len(subordinate_status)):
        subrank_idx.append(fullname_split.index(subordinate_status[srn][1]))
        subrank_name.append(subordinate_status[srn][1])
        subepithet.append(fullname_split[subordinate_status[srn][0]+1])
    fnameCont = []
    for srn in range(0, len(subordinate_status)):
        if srn + 1  == len(subordinate_status):
            authorStopIdx = len(fullname_split)
        else:
            authorStopIdx = subrank_idx[srn + 1]
        fc = ' '.join([subrank_name[srn], subepithet[srn], ' '.join(fullname_split[subrank_idx[srn] + 2: authorStopIdx])])
        fnameCont.append(fc)
    fnameNoAuthors = []
    for srn in range(0, len(subordinate_status)):
        fc = ' '.join([subrank_name[srn], subepithet[srn]])
        fnameNoAuthors.append(fc)
    fullnameNoAuthors = ' '.join([fname_sp, ' '.join(fnameNoAuthors)])

else:
    authors = fullname_split[2:length_fullname]
    authors_join = ' '.join(authors)
    fullnameNoAuthors = ' '.join([fname_sp])
return fullnameNoAuthors

$BODY$;

ALTER FUNCTION public.simplyname(text)
    OWNER TO psilotum;
