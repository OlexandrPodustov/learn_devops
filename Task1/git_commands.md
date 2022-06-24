```
1857 ls
1858 mkdir Task1
1859 cd Task1
1860 touch README.md
1861 g commit -m "task1 changes"
1862 g push origin main
1863 g co -b dev
1864 g add .
1865 g push origin dev
1866 g co -b opodu-new_feature
1867 g co dev
1868 g commit -m "dev branch changes"
1869 g push origin dev
1870 g co opodu-new_feature
1871 touch ./README.md
1872 ls
1873 l
1874 touch .gitignore
1875 g status
1876 g add .
1877 g commit -m "added gitignore"
1878 g push origin opodu-new_feature
1879 g co main
1880 g pull
1881 touch log.txt
1882 git log > log.txt
1883 g status
1884 g add .
1885 g status
1886 g commit -m "added git log"
1887 g push origin main \\n
1888 ;
1889 g status
1890 g branch -d opodu-new_feature
1891 g co -b dev
1892 g branch -d dev
1893 g co -b dev
1894 history| tail 20
1895 history| tail -20
1896 history| tail -40

```
