class ReportBlockAbbreviations extends ReportBlock {
  constructor (section, engine) {
    super(section, engine)
  }
  renderContent () {
    var abbreviations = this.engine.abbreviations.sort(function (a, b) {
      return a.short < b.short ? -1 : a.short > b.short ? 1 : 0
    })
    var table = new ReportTable.Table(abbreviations.length, 2)
    table.style.class = 'noBorders'
    for (var i = 0; i < abbreviations.length; i++) {
      const abbreviation = abbreviations[i]
      table.setData(i, 0, abbreviation.short)
      table.setData(i, 1, abbreviation.plain)
    }
    this.writeTable(table)
  }
}

module.exports = ReportBlockAbbreviations
