/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const { ReportFramework } = require('@reposyd/core')
/* reposyd-reportblock-header */

class ReportBlockAbbreviations extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    /* reposyd-reportblock-constructor */
  }
  /* reposyd-reportblock-body */

  renderContent () {
    var abbreviations = this.engine.abbreviations.sort(function (a, b) {
      return a.short < b.short ? -1 : a.short > b.short ? 1 : 0
    })
    var table = new ReportFramework.Table(abbreviations.length, 2)
    table.style.class = 'noBorders'
    for (var i = 0; i < abbreviations.length; i++) {
      const abbreviation = abbreviations[i]
      table.setData(i, 0, abbreviation.short)
      table.setData(i, 1, abbreviation.plain)
    }
    this.writeTable(table)
  }

  /* reposyd-reportblock-body */
  static DefaultSettings () {
    return {
      reportblock: [],
      section: [
        {
          id: 'pageBreak',
          title: {
            'de-DE': 'Seitenumbruch',
            'en-US': 'Page Break'
          },
          type: 'boolean',
          value: false
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockAbbreviations
