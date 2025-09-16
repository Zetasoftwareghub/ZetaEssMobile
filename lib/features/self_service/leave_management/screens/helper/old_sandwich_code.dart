/*
//TODO old sandwich code  TO BE GIVEN INSIDE THe screen widget
/*  Future getLeaveDetailsByDate(String date, String ltcode) async {
    final responseJson = await Dio().post(
      "${ref.watch(userContextProvider).baseUrl}/api/Leave/GetLeaveDetailsByDate",
      data: {
        "suconn": ref.watch(userContextProvider).companyConnection,
        "date": date,
        "emcode": ref.watch(userContextProvider).empCode,
        "ltcode": ltcode,
      },
      options: dioHeader(token: ref.watch(userContextProvider).jwtToken),
    );
    return responseJson.data['data']['subLst'];
  }*/

/*
  void setSandwich() async {
    List<LeaveConfigurationData> d = leaveConfigData;
    List<LeaveConfigurationData> dSubLst = [];
    final userContext = ref.read(userContextProvider);
    var responseJson = await getLeaveConfigurations(
      widget.dateFrom.toString(),
      widget.dateTo.toString(),
      widget.leaveCode.toString(),
      userContext,
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const NoServer()),
        );
      },
    );

    if (responseJson == null) return;

    try {
      final subLst = (responseJson['subLst'] ?? []) as List;
      for (var item in subLst) {
        dSubLst.add(LeaveConfigurationData.fromJson(item));
      }
    } catch (e) {
      print("Error parsing subLst: $e");
    }

    var includeOff = dSubLst[0].includeOff ?? "N";
    var includeHoliday = dSubLst[0].includeHolliday ?? "N";
    var glapho = dSubLst[0].glapho ?? "N";
    var ltaphl = dSubLst[0].ltaphl ?? "N";

    var trailInclude = false;
    var precInclued = false;

    if (d.first.dayType == 3 || d.first.dayType == 4) {
      DateTime dt = DateFormat('dd/MM/yyyy').parse(d.first.date ?? '');
      dt = dt.add(const Duration(days: -1));
      bool result = true;
      while (result) {
        var responseJsonTra = await getLeaveDetailsByDate(
          dt.toString(),
          widget.leaveCode.toString(),
        ).timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const NoServer()),
            );
          },
        );
        List<LeaveConfigDate> dTra = [];

        for (var i in responseJsonTra) {
          // for (var item in i["SubLst"]) {
          dTra.add(LeaveConfigDate.fromJson(i));
          // }
        }
        if (dTra.isNotEmpty) {
          if (dTra.first.dayType == 1) {
            result = false;
            // if (dPre.first.cLsstat == "Y") { not needed is only Y when leave is approved table
            if (dTra.first.cLsflag == "F") {
              trailInclude = true;
            } else {
              if (dTra.first.halfDayType == "1" &&
                  d.first.date != d.last.date &&
                  d.last.dayType == 1) //gaseer
              {
                trailInclude = true;
              }
              if (dTra.first.halfDayType == "2") {
                trailInclude = true;
              }
            }
          }
        } else {
          result = false;
        }
        dt = dt.add(const Duration(days: -1));
      }
    }

    if (d.last.dayType == 3 || d.last.dayType == 4) {
      DateTime dt = DateFormat('dd/MM/yyyy').parse(d.last.date ?? '');
      dt = dt.add(const Duration(days: 1));
      bool result = true;
      while (result) {
        var responseJsonPre = await getLeaveDetailsByDate(
          dt.toString(),
          widget.leaveCode.toString(),
        ).timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const NoServer()),
            );
          },
        );
        List<LeaveConfigDate> dPre = [];
        for (var i in responseJsonPre) {
          // for (var item in i["SubLst"]) {
          dPre.add(LeaveConfigDate.fromJson(i));
        }
        if (dPre.isNotEmpty) {
          if (dPre.first.dayType == 1) {
            result = false;
            // if (dPre.first.cLsstat == "Y") { not needed is only Y when leave is approved table
            if (dPre.first.cLsflag == "F") {
              precInclued = true;
            } else {
              if (dPre.first.halfDayType == "2" &&
                  d.first.date != d.last.date &&
                  d.first.dayType == 1) //gaseer
              {
                precInclued = true;
              }
              if (dPre.first.halfDayType == "1") {
                precInclued = true;
              }
            }
          }
        } else {
          result = false;
        }
        dt = dt.add(const Duration(days: 1));
      }
    }

    DateTime fromDate = DateFormat('dd/MM/yyyy').parse(d.first.date ?? '');
    DateTime toDate = DateFormat('dd/MM/yyyy').parse(d.last.date ?? '');

    DateTime startDate = DateFormat('dd/MM/yyyy').parse(d.first.date ?? '');
    DateTime endDate = DateFormat('dd/MM/yyyy').parse(d.last.date ?? '');

    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      var startDateStr = DateFormat('dd/MM/yyyy').format(startDate);
      var itemLst = d.where((element) => element.date == startDateStr);
      if (itemLst.isNotEmpty) {
        var item = itemLst.first;
        if (item.dayType == 3 || item.dayType == 4) {
          if (ltaphl == "N") {
            if (item.dayType == 3) {
              if (includeOff == "N") {
                d
                    .firstWhere((element) => element.date == startDateStr)
                    .dayFlag = 'X';
              } else {
                d
                    .firstWhere((element) => element.date == startDateStr)
                    .dayFlag = 'F';
              }
            } else if (item.dayType == 4) {
              if (includeHoliday == "N") {
                d
                    .firstWhere((element) => element.date == startDateStr)
                    .dayFlag = 'X';
              } else {
                d
                    .firstWhere((element) => element.date == startDateStr)
                    .dayFlag = 'F';
              }
            }
          } else {
            if (glapho == "N") //None
            {
              if (item.dayType == 3) {
                if (includeOff == "N") {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = 'X';
                } else {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = 'F';
                }
              } else if (item.dayType == 4) {
                if (includeHoliday == "N") {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = 'X';
                } else {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = 'F';
                }
              }
            } else {
              bool prec = false;
              bool trail = false;
              //TODO check the preceeding and trailing
              if (d.first.dayType == 3 || d.first.dayType == 4) {
                if (trailInclude) {
                  trail = true;
                }
              }

              if (d.last.dayType == 3 || d.last.dayType == 4) {
                if (precInclued) {
                  prec = true;
                }
              }

              DateTime selDate = DateFormat(
                'dd/MM/yyyy',
              ).parse(item.date ?? '');

              while (selDate.isAfter(fromDate) ||
                  selDate.isAtSameMomentAs(fromDate)) {
                var selDateStr = DateFormat('dd/MM/yyyy').format(selDate);
                var itemLstTra = d.where(
                  (element) => element.date == selDateStr,
                );
                if (itemLstTra.isNotEmpty) {
                  var itemPre = itemLstTra.first;
                  if (itemPre.dayType == 1) {
                    if (d.first.date != d.last.date &&
                        d.last.dayType == 1 &&
                        itemPre.halfType == '1') {
                      trail = true;
                    }
                    if (itemPre.dayFlag == "F" || itemPre.halfType == '2') {
                      trail = true;
                    }
                    break;
                  }
                }
                selDate = selDate.add(const Duration(days: -1));
              }

              selDate = DateFormat('dd/MM/yyyy').parse(item.date ?? '');
              while (selDate.isBefore(toDate) ||
                  selDate.isAtSameMomentAs(toDate)) {
                var selDateStr = DateFormat('dd/MM/yyyy').format(selDate);
                var itemLstPre = d.where(
                  (element) => element.date == selDateStr,
                );
                if (itemLstPre.isNotEmpty) {
                  var itemTra = itemLstPre.first;
                  if (itemTra.dayType == 1) {
                    if (itemTra.halfType == '2' &&
                        d.first.date != d.last.date &&
                        d.first.dayType == 1) {
                      prec = true;
                    }
                    if (itemTra.dayFlag == "F" || itemTra.halfType == '1') {
                      prec = true;
                    }
                    break;
                  }
                }
                selDate = selDate.add(const Duration(days: 1));
              }

              if (glapho == "S") //Preceding & Trailing
              {
                // if (true) {
                if (prec == true && trail == true) {
                  //TODO adjusted the code to only check the preceeding before the code was  (prec==true && trail ==true)
                  if (item.dayType == 3) {
                    if (includeOff == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  } else if (item.dayType == 4) {
                    if (includeHoliday == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  }
                } else {
                  //TODO ths is the issue

                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = '';
                }
              } else if (glapho == "Y") //Preceding or Trailing
              {
                if (prec == true || trail == true) {
                  if (item.dayType == 3) {
                    if (includeOff == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  } else if (item.dayType == 4) {
                    if (includeHoliday == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  }
                } else {
                  if ((item.dayType == 3 && includeOff == "Y") ||
                      (item.dayType == 4 && includeHoliday == 'Y')) {
                    d
                        .firstWhere((element) => element.date == startDateStr)
                        .dayFlag = 'F';
                  } else {
                    d
                        .firstWhere((element) => element.date == startDateStr)
                        .dayFlag = '';
                  } //TODO check this is not correct I think Include off correction
                }
              } else if (glapho == "P") //Preceding
              {
                if (prec == true) {
                  if (item.dayType == 3) {
                    if (includeOff == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  } else if (item.dayType == 4) {
                    if (includeHoliday == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  }
                } else {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = '';
                }
              } else if (glapho == "T") //Trailing
              {
                if (trail == true) {
                  if (item.dayType == 3) {
                    if (includeOff == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  } else if (item.dayType == 4) {
                    if (includeHoliday == "N") {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'X';
                    } else {
                      d
                          .firstWhere((element) => element.date == startDateStr)
                          .dayFlag = 'F';
                    }
                  }
                } else {
                  d
                      .firstWhere((element) => element.date == startDateStr)
                      .dayFlag = '';
                }
              }
            }
          }
        }
      }
      startDate = startDate.add(const Duration(days: 1));
    }
    //.hide();
    setState(() {
      leaveConfigData = d;
    });

    leaveController.setData(d);
    setState(() => isLoading = false); //TODO check the loading
  }*/*/
